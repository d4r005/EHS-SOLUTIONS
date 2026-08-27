import { createContext, useContext, useState, useEffect } from 'react';
import axios from 'axios';
import { rest, SUPABASE_URL, SUPABASE_KEY } from '../services/api';

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

  // Helper para headers (usado solo para llamadas a /auth que no van por 'rest')
  const getAuthHeaders = (accessToken = null) => {
    const headers = {
      'apikey': SUPABASE_KEY,
      'Content-Type': 'application/json'
    };
    const finalToken = accessToken || token || localStorage.getItem('token');
    if (finalToken) {
      headers['Authorization'] = `Bearer ${finalToken}`;
    }
    return headers;
  };

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
      // Petición a Supabase Auth para validar el token y obtener metadatos
      const authRes = await axios.get(`${SUPABASE_URL}/auth/v1/user`, {
        headers: getAuthHeaders(),
      });

      // Petición a nuestra tabla pública de perfiles usando la instancia 'rest' con interceptores
      let profileRes = await rest.get(`/users?auth_id=eq.${authRes.data.id}&select=id,first_name,last_name,email,role`);

      if (!profileRes.data.length) {
        profileRes = await rest.get(`/users?email=eq.${authRes.data.email}&select=id,first_name,last_name,email,role`);

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
        });
        localStorage.setItem('userId', profile.id);
      } else {
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
      // El interceptor de api.js ya maneja el 401 y el logout si el refresco falla
    } finally {
      setLoading(false);
    }
  };

  const register = async (firstName, lastName, email, password) => {
    setLoading(true);
    setError(null);
    try {
      const signupRes = await axios.post(
        `${SUPABASE_URL}/auth/v1/signup`,
        {
          email,
          password,
          data: { first_name: firstName, last_name: lastName, role: 'student' }
        },
        { headers: getAuthHeaders() }
      );

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

      let profileRes;
      let retries = 5;
      while (retries > 0) {
        profileRes = await rest.get(`/users?auth_id=eq.${authId}&select=id,first_name,last_name,email,role`);
        if (profileRes.data.length > 0) break;
        await new Promise(resolve => setTimeout(resolve, 800));
        retries--;
      }

      if (profileRes.data.length === 0) {
        throw new Error('Cuenta creada, pero hubo un retraso sincronizando tu perfil. Por favor intenta iniciar sesión en unos momentos.');
      }

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
      localStorage.setItem('userId', profile.id);
      return true;
    } catch (err) {
      console.error('Error en registro:', err);
      const msg = err.response?.data?.msg || err.response?.data?.message || err.message;
      setError(msg || 'Error al registrarse');
      return false;
    } finally {
      setLoading(false);
    }
  };

  const login = async (email, password) => {
    setLoading(true);
    setError(null);
    try {
      const loginRes = await axios.post(
        `${SUPABASE_URL}/auth/v1/token?grant_type=password`,
        { email, password },
        { headers: getAuthHeaders() }
      );

      const accessToken = loginRes.data.access_token;
      const refreshToken = loginRes.data.refresh_token;
      const authId = loginRes.data.user.id;

      localStorage.setItem('token', accessToken);
      localStorage.setItem('refreshToken', refreshToken);

      let profileRes = await rest.get(`/users?auth_id=eq.${authId}&select=id,first_name,last_name,email,role`);

      if (!profileRes.data.length) {
        profileRes = await rest.get(`/users?email=eq.${email}&select=id,first_name,last_name,email,role`);
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
      return true;
    } catch (err) {
      console.error('Error en login:', err);
      const msg = err.response?.data?.error_description || err.response?.data?.message || 'Email o contraseña incorrectos';
      setError(msg);
      return false;
    } finally {
      setLoading(false);
    }
  };

  const logout = () => {
    setToken(null);
    setUser(null);
    localStorage.removeItem('token');
    localStorage.removeItem('refreshToken');
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
