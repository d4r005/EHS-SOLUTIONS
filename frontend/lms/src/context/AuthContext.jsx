import { createContext, useContext, useState, useEffect } from 'react';
import axios from 'axios';
import { rest, authApi, SUPABASE_URL, SUPABASE_KEY, clearSessionAndRedirect } from '../services/api';

const AuthContext = createContext();

if (!SUPABASE_KEY) {
  console.error('⚠️ ERROR: VITE_SUPABASE_KEY no encontrada.');
}

export const AuthProvider = ({ children }) => {
  const [user, setUser] = useState(null);
  const [token, setToken] = useState(localStorage.getItem('token'));
  // `initializing`: controla el spinner de pantalla completa (App.jsx) y el
  // gate de ProtectedRoute. Se activa SOLO cuando hay un token que cargar
  // (al abrir la web, o justo después de un login/registro exitoso, vía el
  // useEffect de abajo) — nunca directamente dentro de register()/login(),
  // para no desmontar la página actual (y borrar sus mensajes) mientras
  // esas peticiones están en curso.
  const [initializing, setInitializing] = useState(!!localStorage.getItem('token'));
  // `loading`: solo para los botones de los formularios de login/registro
  // (disabled + texto "Cargando..."). No afecta el render del resto de la app.
  const [loading, setLoading] = useState(false);
  const [error, setError] = useState(null);

  useEffect(() => {
    if (token) {
      localStorage.setItem('token', token);
      setInitializing(true);
      fetchProfile();
    } else {
      setInitializing(false);
    }
  }, [token]);

  const fetchProfile = async () => {
    try {
      // 1) Obtener datos del JWT (funciona sin tocar tabla users)
      const authRes = await authApi.get('/user');
      const email = authRes.data.email;
      const first_name = authRes.data.user_metadata?.first_name || '';
      const last_name = authRes.data.user_metadata?.last_name || '';
      const jwtRole = authRes.data.user_metadata?.role || 'student';

      // 2) Obtener ID, role y nombres reales de la BD via RPC o tabla
      let dbId = 0;
      let dbRole = jwtRole;
      let dbNombres = first_name;
      let dbPaterno = last_name;
      let dbMaterno = '';

      try {
        const idRes = await rest.post('/rpc/current_user_id', {});
        dbId = idRes.data || 0;

        // Cargar datos extra del perfil (Incluyendo teléfono y bio)
        if (dbId) {
          const { data: userData } = await rest.get(`/users?id=eq.${dbId}&select=nombres,apellido_paterno,apellido_materno,role,phone,bio`);
          if (userData?.[0]) {
            dbNombres = userData[0].nombres || dbNombres;
            dbPaterno = userData[0].apellido_paterno || dbPaterno;
            dbMaterno = userData[0].apellido_materno || '';
            dbRole = userData[0].role || dbRole;
            // Guardar teléfono y bio en el estado global
            setUser({
              id: dbId,
              first_name: dbNombres,
              last_name: `${dbPaterno} ${dbMaterno}`.trim(),
              nombres: dbNombres,
              apellido_paterno: dbPaterno,
              apellido_materno: dbMaterno,
              phone: userData[0].phone || '',
              bio: userData[0].bio || '',
              email,
              role: dbRole,
            });
            localStorage.setItem('userId', String(dbId));
            setError(null);
            setInitializing(false);
            return; // Salir aquí ya que actualizamos todo
          }
        }
      } catch (e) {
        console.warn('No se pudo obtener datos completos de la BD, usando JWT', e);
      }

      setUser({
        id: dbId,
        first_name: dbNombres, // Mantenemos compatible por ahora
        last_name: `${dbPaterno} ${dbMaterno}`.trim(),
        nombres: dbNombres,
        apellido_paterno: dbPaterno,
        apellido_materno: dbMaterno,
        email,
        role: dbRole,
      });
      localStorage.setItem('userId', String(dbId));
      setError(null);
    } catch (err) {
      console.error('Error al cargar perfil:', err);
      if (err.response?.status !== 401) {
        logout();
      }
    } finally {
      setInitializing(false);
    }
  };

  const register = async (nombres, apellidoPaterno, apellidoMaterno, email, password) => {
    setLoading(true);
    setError(null);
    try {
      localStorage.removeItem('token');
      localStorage.removeItem('refreshToken');

      // redirect_to: a donde Supabase manda al usuario tras confirmar su correo.
      // Se envia tanto como query param como en el body, porque distintas
      // versiones de GoTrue lo leen de distintos lugares.
      const emailRedirectTo = `${window.location.origin}/app/auth/callback`;
      const signupRes = await authApi.post(
        `/signup?redirect_to=${encodeURIComponent(emailRedirectTo)}`,
        {
          email,
          password,
          data: {
            first_name: nombres,
            last_name: `${apellidoPaterno} ${apellidoMaterno}`.trim(),
            nombres: nombres,
            apellido_paterno: apellidoPaterno,
            apellido_materno: apellidoMaterno,
            role: 'student'
          },
          options: {
            emailRedirectTo: emailRedirectTo,
          }
        }
      );

      setLoading(false);

      if (!signupRes.data.access_token) {
        const msg = 'Registro exitoso. Revisa tu correo para confirmar tu cuenta antes de iniciar sesión.';
        setError(msg);
        return { success: false, needsConfirmation: true, message: msg };
      }

      // Hay sesión inmediata (confirmación de correo desactivada en Supabase):
      // esto dispara el useEffect de arriba -> fetchProfile() -> initializing.
      localStorage.setItem('token', signupRes.data.access_token);
      localStorage.setItem('refreshToken', signupRes.data.refresh_token);
      setToken(signupRes.data.access_token);
      return { success: true };
    } catch (err) {
      console.error('Error en registro:', err);
      let msg = err.response?.data?.msg || err.response?.data?.message || err.message;
      // Mensaje más claro para el caso de rate-limit de emails de Supabase
      if (err.response?.data?.error_code === 'over_email_send_rate_limit') {
        msg = 'Se alcanzó el límite de correos de confirmación por ahora. Espera unos minutos e intenta de nuevo.';
      }
      setError(msg || 'Error al registrarse');
      setLoading(false);
      return { success: false, needsConfirmation: false, message: msg || 'Error al registrarse' };
    }
  };

  const login = async (email, password) => {
    setLoading(true);
    setError(null);
    try {
      localStorage.removeItem('token');
      localStorage.removeItem('refreshToken');

      const loginRes = await authApi.post('/token?grant_type=password', { email, password });

      setLoading(false);
      localStorage.setItem('token', loginRes.data.access_token);
      localStorage.setItem('refreshToken', loginRes.data.refresh_token);
      // Dispara el useEffect -> fetchProfile() -> initializing.
      setToken(loginRes.data.access_token);
      return true;
    } catch (err) {
      console.error('Error en login:', err);
      const msg = err.response?.data?.error_description || err.response?.data?.message || 'Email o contraseña incorrectos';
      setError(msg);
      setLoading(false);
      return false;
    }
  };

  const logout = () => {
    setUser(null);
    setToken(null);
    clearSessionAndRedirect();
  };

  // Se usa cuando el usuario vuelve del enlace de confirmación de correo de
  // Supabase (ver AuthCallbackPage). Guarda los tokens recibidos en el hash
  // de la URL y dispara la carga del perfil (vía el useEffect de arriba).
  const confirmSession = (accessToken, refreshToken) => {
    localStorage.setItem('token', accessToken);
    if (refreshToken) localStorage.setItem('refreshToken', refreshToken);
    setError(null);
    setToken(accessToken);
  };

  const value = {
    user,
    token,
    initializing,
    loading,
    error,
    register,
    login,
    logout,
    confirmSession,
    isAuthenticated: !!user && !!token,
  };

  return <AuthContext.Provider value={value}>{children}</AuthContext.Provider>;
};

export const useAuth = () => {
  const context = useContext(AuthContext);
  if (!context) {
    throw new Error('useAuth debe usarse dentro de AuthProvider');
  }
  return context;
};
