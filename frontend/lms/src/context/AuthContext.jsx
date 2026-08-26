import { createContext, useContext, useState, useEffect } from 'react';
import axios from 'axios';

const AuthContext = createContext();

// ============================================
// Auth con Supabase Auth (sin backend propio)
// ============================================
const SUPABASE_URL = import.meta.env.VITE_SUPABASE_URL || 'https://tsqlpjliqslgzookdqvg.supabase.co';
const SUPABASE_KEY = import.meta.env.VITE_SUPABASE_KEY;

export const AuthProvider = ({ children }) => {
  const [user, setUser] = useState(null);
  const [token, setToken] = useState(localStorage.getItem('token'));
  const [loading, setLoading] = useState(false);
  const [error, setError] = useState(null);

  // Cargar perfil al montar si hay token
  useEffect(() => {
    if (token) {
      localStorage.setItem('token', token);
      fetchProfile();
    }
  }, [token]);

  const fetchProfile = async () => {
    try {
      // Obtener usuario de Supabase Auth
      const authRes = await axios.get(`${SUPABASE_URL}/auth/v1/user`, {
        headers: { apikey: SUPABASE_KEY, Authorization: `Bearer ${token}` },
      });

      // 2. Obtener perfil de public.users usando auth_id (más confiable) o email
      let profileRes = await axios.get(
        `${SUPABASE_URL}/rest/v1/users?auth_id=eq.${authRes.data.id}&select=id,first_name,last_name,email,role`,
        { headers: { apikey: SUPABASE_KEY, Authorization: `Bearer ${token}` } }
      );

      // Si no lo encuentra por auth_id, intentar por email y vincularlo
      if (!profileRes.data.length) {
        profileRes = await axios.get(
          `${SUPABASE_URL}/rest/v1/users?email=eq.${authRes.data.email}&select=id,first_name,last_name,email,role`,
          { headers: { apikey: SUPABASE_KEY, Authorization: `Bearer ${token}` } }
        );

        if (profileRes.data.length) {
          // Vincular auth_id al usuario existente
          await axios.patch(
            `${SUPABASE_URL}/rest/v1/users?id=eq.${profileRes.data[0].id}`,
            { auth_id: authRes.data.id },
            { headers: { apikey: SUPABASE_KEY, Authorization: `Bearer ${token}` } }
          );
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
        });
        localStorage.setItem('userId', profile.id);
      } else {
        // Usuario existe en Auth pero no en public.users - usar metadata
        // El trigger de Supabase debería haber creado esto, pero usamos esto como red de seguridad
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
      console.error('Error fetching profile:', err);
      // Solo desconectar si es un error de token inválido (401), no de red
      if (err.response?.status === 401) {
        setToken(null);
        setUser(null);
        localStorage.removeItem('token');
        localStorage.removeItem('userId');
      }
    }
  };

  const register = async (firstName, lastName, email, password) => {
    setLoading(true);
    setError(null);
    try {
      // 1. Signup en Supabase Auth
      await axios.post(
        `${SUPABASE_URL}/auth/v1/signup`,
        {
          email,
          password,
          data: { first_name: firstName, last_name: lastName, role: 'student' }
        },
        { headers: { apikey: SUPABASE_KEY, 'Content-Type': 'application/json' } }
      );

      // 2. Login para obtener token
      const loginRes = await axios.post(
        `${SUPABASE_URL}/auth/v1/token?grant_type=password`,
        { email, password },
        { headers: { apikey: SUPABASE_KEY, 'Content-Type': 'application/json' } }
      );
      const accessToken = loginRes.data.access_token;
      const authId = loginRes.data.user.id;

      // 3. Insertar en public.users con auth_id
      await axios.post(
        `${SUPABASE_URL}/rest/v1/users`,
        {
          auth_id: authId,
          first_name: firstName,
          last_name: lastName,
          email,
          password: 'managed_by_auth',
          role: 'student',
          is_active: true
        },
        { headers: { apikey: SUPABASE_KEY, Authorization: `Bearer ${accessToken}`, 'Content-Type': 'application/json' } }
      );

      // 4. Obtener perfil
      const profileRes = await axios.get(
        `${SUPABASE_URL}/rest/v1/users?auth_id=eq.${authId}&select=id,first_name,last_name,email,role`,
        { headers: { apikey: SUPABASE_KEY, Authorization: `Bearer ${accessToken}` } }
      );

      const profile = profileRes.data[0];
      const newUser = {
        id: profile.id,
        first_name: profile.first_name,
        last_name: profile.last_name,
        email: profile.email,
        role: profile.role,
      };

      setToken(accessToken);
      setUser(newUser);
      localStorage.setItem('token', accessToken);
      localStorage.setItem('userId', profile.id);
      return true;
    } catch (err) {
      const message = err.response?.data?.msg || err.response?.data?.message || 'Error al registrarse';
      setError(message);
      return false;
    } finally {
      setLoading(false);
    }
  };

  const login = async (email, password) => {
    setLoading(true);
    setError(null);
    try {
      // 1. Login con Supabase Auth
      const loginRes = await axios.post(
        `${SUPABASE_URL}/auth/v1/token?grant_type=password`,
        { email, password },
        { headers: { apikey: SUPABASE_KEY, 'Content-Type': 'application/json' } }
      );
      const accessToken = loginRes.data.access_token;
      const authId = loginRes.data.user.id;

      // 2. Obtener perfil de public.users
      let profileRes = await axios.get(
        `${SUPABASE_URL}/rest/v1/users?auth_id=eq.${authId}&select=id,first_name,last_name,email,role`,
        { headers: { apikey: SUPABASE_KEY, Authorization: `Bearer ${accessToken}` } }
      );

      // Fallback por email si no tiene auth_id vinculado
      if (!profileRes.data.length) {
        profileRes = await axios.get(
          `${SUPABASE_URL}/rest/v1/users?email=eq.${email}&select=id,first_name,last_name,email,role`,
          { headers: { apikey: SUPABASE_KEY, Authorization: `Bearer ${accessToken}` } }
        );

        if (profileRes.data.length) {
          // Vincular auth_id ahora
          await axios.patch(
            `${SUPABASE_URL}/rest/v1/users?id=eq.${profileRes.data[0].id}`,
            { auth_id: authId },
            { headers: { apikey: SUPABASE_KEY, Authorization: `Bearer ${accessToken}` } }
          );
        }
      }

      let newUser;
      if (profileRes.data.length) {
        const profile = profileRes.data[0];
        newUser = {
          id: profile.id,
          first_name: profile.first_name,
          last_name: profile.last_name,
          email: profile.email,
          role: profile.role,
        };
        localStorage.setItem('userId', profile.id);
      } else {
        // Fallback: usar metadata de Auth
        newUser = {
          id: 0,
          first_name: loginRes.data.user?.user_metadata?.first_name || '',
          last_name: loginRes.data.user?.user_metadata?.last_name || '',
          email: loginRes.data.user?.email || email,
          role: loginRes.data.user?.user_metadata?.role || 'student',
        };
        localStorage.setItem('userId', '0');
      }

      setToken(accessToken);
      setUser(newUser);
      localStorage.setItem('token', accessToken);
      return true;
    } catch (err) {
      const message = err.response?.data?.error_description || err.response?.data?.message || 'Email o contraseña incorrectos';
      setError(message);
      return false;
    } finally {
      setLoading(false);
    }
  };

  const logout = () => {
    setToken(null);
    setUser(null);
    localStorage.removeItem('token');
    localStorage.removeItem('userId');
  };

  const value = {
    user,
    token,
    loading,
    error,
    register,
    login,
    logout,
    isAuthenticated: !!token,
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
