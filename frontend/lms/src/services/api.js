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

// Interceptor de solicitud para añadir el token
rest.interceptors.request.use(
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

// Interceptor de respuesta para manejar la expiración del token (401)
rest.interceptors.response.use(
  (response) => response,
  async (error) => {
    const originalRequest = error.config;

    // Si el error es 401 y no hemos reintentado ya
    if (error.response?.status === 401 && !originalRequest._retry) {
      originalRequest._retry = true;
      const refreshToken = localStorage.getItem('refreshToken');

      if (refreshToken) {
        try {
          // Intentar refrescar el token usando el endpoint de Supabase Auth
          const res = await axios.post(
            `${SUPABASE_URL}/auth/v1/token?grant_type=refresh_token`,
            { refresh_token: refreshToken },
            {
              headers: {
                apikey: SUPABASE_KEY,
                'Content-Type': 'application/json',
              },
            }
          );

          const { access_token, refresh_token } = res.data;

          // Guardar los nuevos tokens
          localStorage.setItem('token', access_token);
          localStorage.setItem('refreshToken', refresh_token);

          // Reintentar la petición original con el nuevo token
          originalRequest.headers.Authorization = `Bearer ${access_token}`;
          return rest(originalRequest);
        } catch (refreshError) {
          console.error('Error al refrescar el token:', refreshError);
          // Si el refresco falla, cerrar sesión
          localStorage.removeItem('token');
          localStorage.removeItem('refreshToken');
          localStorage.removeItem('userId');
          window.location.href = '/login';
        }
      } else {
        // No hay refresh token, redirigir al login
        window.location.href = '/login';
      }
    }

    return Promise.reject(error);
  }
);

export { rest, SUPABASE_URL, SUPABASE_KEY };
export default rest;
