import axios from 'axios';

const SUPABASE_URL = import.meta.env.VITE_SUPABASE_URL || 'https://tsqlpjliqslgzookdqvg.supabase.co';
const SUPABASE_KEY = import.meta.env.VITE_SUPABASE_KEY;

// Instancia para PostgREST
const rest = axios.create({
  baseURL: `${SUPABASE_URL}/rest/v1`,
  headers: {
    apikey: SUPABASE_KEY,
    'Content-Type': 'application/json',
  },
});

// Instancia para Supabase Auth ( /auth/v1 )
const authApi = axios.create({
  baseURL: `${SUPABASE_URL}/auth/v1`,
  headers: {
    apikey: SUPABASE_KEY,
    'Content-Type': 'application/json',
  },
});

// Función centralizada para limpiar sesión y redirigir
const clearSessionAndRedirect = () => {
  localStorage.removeItem('token');
  localStorage.removeItem('refreshToken');
  localStorage.removeItem('userId');
  // Evitar bucles de redirección si ya estamos en login o home
  if (!window.location.pathname.includes('/login') && window.location.pathname !== '/') {
    window.location.href = '/app/login';
  }
};

const setupInterceptors = (instance) => {
  instance.interceptors.request.use(
    (config) => {
      const token = localStorage.getItem('token');
      if (token) {
        config.headers.Authorization = `Bearer ${token}`;
      } else {
        config.headers.Authorization = `Bearer ${SUPABASE_KEY}`;
      }
      return config;
    },
    (error) => Promise.reject(error)
  );

  instance.interceptors.response.use(
    (response) => response,
    async (error) => {
      const originalRequest = error.config;

      // Si el error es 401 y no hemos reintentado
      if (error.response?.status === 401 && !originalRequest._retry) {
        originalRequest._retry = true;
        const refreshToken = localStorage.getItem('refreshToken');

        if (refreshToken) {
          try {
            const res = await axios.post(
              `${SUPABASE_URL}/auth/v1/token?grant_type=refresh_token`,
              { refresh_token: refreshToken },
              { headers: { apikey: SUPABASE_KEY, 'Content-Type': 'application/json' } }
            );

            const { access_token, refresh_token } = res.data;
            localStorage.setItem('token', access_token);
            localStorage.setItem('refreshToken', refresh_token);

            originalRequest.headers.Authorization = `Bearer ${access_token}`;
            return instance(originalRequest);
          } catch (refreshError) {
            console.error('Error al refrescar token:', refreshError);
            clearSessionAndRedirect();
          }
        } else {
          clearSessionAndRedirect();
        }
      }
      return Promise.reject(error);
    }
  );
};

setupInterceptors(rest);
setupInterceptors(authApi);

export { rest, authApi, SUPABASE_URL, SUPABASE_KEY, clearSessionAndRedirect };
export default rest;
