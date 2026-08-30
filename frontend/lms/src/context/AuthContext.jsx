import { createContext, useContext, useState, useEffect } from 'react';
import axios from 'axios';
import { rest, authApi, SUPABASE_URL, SUPABASE_KEY, clearSessionAndRedirect } from '../services/api';

const AuthContext = createContext();

// Debug: Verificar si las llaves están cargadas
if (!SUPABASE_KEY) {
  console.error('⚠️ ERROR: VITE_SUPABASE_KEY no encontrada. Asegúrate de haber creado el archivo .env y reiniciado el servidor (npm run dev).');
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
      // Petición a Supabase Auth usando authApi (protegido por interceptor)
      const authRes = await authApi.get('/user');

      // Petición a nuestra tabla pública de perfiles
      let profileRes = await rest.get(`/users?auth_id=eq.${authRes.data.id}&select=id,first_name,last_name,email,role,curp,ocupacion,company_rfc`);

      if (!profileRes.data.length) {
        profileRes = await rest.get(`/users?email=eq.${authRes.data.email}&select=id,first_name,last_name,email,role,curp,ocupacion,company_rfc`);

        if (profileRes.data.length) {
          await rest.patch(`/users?id=eq.${profileRes.data[0].id}`, { auth_id: authRes.data.id });
        }
      }

      if (profileRes.data.length) {
        const profile = profileRes.data[0];
        setUser({
          id: profile.id,
          first_name: profile.first_name,
          last_name: profile.last_name,
          email: profile.email,
          role: profile.role,
          curp: profile.curp,
          ocupacion: profile.ocupacion,
          company_rfc: profile.company_rfc,
        });
        localStorage.setItem('userId', profile.id);
      } else {
        // Usuario autenticado en Supabase Auth pero sin fila en tabla 'users'
        setUser({
          id: 0,
          first_name: authRes.data.user_metadata?.first_name || '',
          last_name: authRes.data.user_metadata?.last_name || '',
          email: authRes.data.email,
          role: authRes.data.user_metadata?.role || 'student',
        });
        localStorage.setItem('userId', '0');
      }
      setError(null);
    } catch (err) {
      console.error('Error al cargar perfil:', err);
      // Si el error es 401, el interceptor de api.js ya llamó a clearSessionAndRedirect
      // En cualquier otro error grave, limpiamos estado local
      if (err.response?.status !== 401) {
        logout();
      }
    } finally {
      setLoading(false);
    }
  };

  const register = async (firstName, lastName, email, password) => {
    setLoading(true);
    setError(null);
    try {
      // Limpiar rastro de sesión previa
      localStorage.removeItem('token');
      localStorage.removeItem('refreshToken');

      const signupRes = await authApi.post('/signup', {
        email,
        password,
        data: { first_name: firstName, last_name: lastName, role: 'student' }
      });

      if (!signupRes.data.access_token) {
        setError('Registro exitoso. Revisa tu correo para confirmar tu cuenta antes de iniciar sesión.');
        setLoading(false);
        return false;
      }

      const accessToken = signupRes.data.access_token;
      const refreshToken = signupRes.data.refresh_token;
      const authId = signupRes.data.user.id;

      localStorage.setItem('token', accessToken);
      localStorage.setItem('refreshToken', refreshToken);
      setToken(accessToken); // Esto disparará useEffect -> fetchProfile

      return true;
    } catch (err) {
      console.error('Error en registro:', err);
      const msg = err.response?.data?.msg || err.response?.data?.message || err.message;
      setError(msg || 'Error al registrarse');
      setLoading(false);
      return false;
    }
  };

  const login = async (email, password) => {
    setLoading(true);
    setError(null);
    try {
      // Limpiar rastro de sesión previa antes de intentar login nuevo
      localStorage.removeItem('token');
      localStorage.removeItem('refreshToken');

      const loginRes = await authApi.post('/token?grant_type=password', { email, password });

      const accessToken = loginRes.data.access_token;
      const refreshToken = loginRes.data.refresh_token;

      localStorage.setItem('token', accessToken);
      localStorage.setItem('refreshToken', refreshToken);
      setToken(accessToken); // Esto disparará useEffect -> fetchProfile

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

  const value = {
    user,
    token,
    loading,
    error,
    register,
    login,
    logout,
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
