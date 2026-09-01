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
  const [loading, setLoading] = useState(!!localStorage.getItem('token'));
  const [error, setError] = useState(null);

  useEffect(() => {
    if (token) {
      localStorage.setItem('token', token);
      fetchProfile();
    } else {
      setLoading(false);
    }
  }, [token]);

  const fetchProfile = async () => {
    try {
      setLoading(true);
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
            setLoading(false);
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
      setLoading(false);
    }
  };

  const register = async (nombres, apellidoPaterno, apellidoMaterno, email, password) => {
    setLoading(true);
    setError(null);
    try {
      localStorage.removeItem('token');
      localStorage.removeItem('refreshToken');

      // redirect_to: a donde Supabase manda al usuario tras confirmar su correo
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
          }
        }
      );

      if (!signupRes.data.access_token) {
        const msg = 'Registro exitoso. Revisa tu correo para confirmar tu cuenta antes de iniciar sesión.';
        setError(msg);
        setLoading(false);
        return { success: false, needsConfirmation: true, message: msg };
      }

      localStorage.setItem('token', signupRes.data.access_token);
      localStorage.setItem('refreshToken', signupRes.data.refresh_token);
      setToken(signupRes.data.access_token);
      return { success: true };
    } catch (err) {
      console.error('Error en registro:', err);
      const msg = err.response?.data?.msg || err.response?.data?.message || err.message;
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

      localStorage.setItem('token', loginRes.data.access_token);
      localStorage.setItem('refreshToken', loginRes.data.refresh_token);
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
  // de la URL y dispara la carga del perfil.
  const confirmSession = (accessToken, refreshToken) => {
    localStorage.setItem('token', accessToken);
    if (refreshToken) localStorage.setItem('refreshToken', refreshToken);
    setError(null);
    setToken(accessToken);
  };

  const value = {
    user,
    token,
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
