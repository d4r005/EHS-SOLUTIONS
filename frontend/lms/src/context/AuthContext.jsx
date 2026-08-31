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

      // 2) Obtener ID y role reales de la BD via RPC (bypassa RLS)
      let dbId = 0;
      let dbRole = jwtRole;
      try {
        const idRes = await rest.post('/rpc/current_user_id', {});
        dbId = idRes.data || 0;
      } catch (e) {
        console.warn('No se pudo obtener ID via RPC, usando 0', e);
      }
      try {
        const roleRes = await rest.post('/rpc/current_user_role', {});
        dbRole = roleRes.data || jwtRole;
      } catch (e) {
        console.warn('No se pudo obtener role via RPC, usando JWT', e);
      }

      setUser({
        id: dbId,
        first_name,
        last_name,
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

  const register = async (firstName, lastName, email, password) => {
    setLoading(true);
    setError(null);
    try {
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

      localStorage.setItem('token', signupRes.data.access_token);
      localStorage.setItem('refreshToken', signupRes.data.refresh_token);
      setToken(signupRes.data.access_token);
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
