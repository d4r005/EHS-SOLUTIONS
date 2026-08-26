import axios from 'axios';

// URL de la Edge Function de Supabase
const API_URL = import.meta.env.VITE_API_URL || 'https://tsqlpjliqslgzookdqvg.supabase.co/functions/v1/api';

const api = axios.create({
  baseURL: API_URL,
});

// Interceptor para agregar token automáticamente
api.interceptors.request.use(
  (config) => {
    const token = localStorage.getItem('token');
    if (token) {
      config.headers.Authorization = `Bearer ${token}`;
    }
    return config;
  },
  (error) => Promise.reject(error)
);

export const courseService = {
  // Obtener todos los cursos
  getCourses: async (filters = {}) => {
    try {
      const response = await api.get('/courses', { params: filters });
      return response.data;
    } catch (error) {
      throw error.response?.data || error;
    }
  },

  // Obtener detalle de un curso
  getCourseById: async (id) => {
    try {
      const response = await api.get(`/courses/${id}`);
      return response.data;
    } catch (error) {
      throw error.response?.data || error;
    }
  },

  // Inscribirse a un curso
  enrollCourse: async (courseId) => {
    try {
      const response = await api.post('/enrollments', { course_id: courseId });
      return response.data;
    } catch (error) {
      throw error.response?.data || error;
    }
  },

  // Obtener mis cursos
  getMyCourses: async () => {
    try {
      const response = await api.get('/enrollments');
      return response.data;
    } catch (error) {
      throw error.response?.data || error;
    }
  },

  // Obtener módulos de un curso
  getModules: async (courseId) => {
    try {
      const response = await api.get(`/modules?course_id=${courseId}`);
      return response.data;
    } catch (error) {
      throw error.response?.data || error;
    }
  },

  // Obtener lecciones de un módulo
  getLessons: async (moduleId) => {
    try {
      const response = await api.get(`/lessons?module_id=${moduleId}`);
      return response.data;
    } catch (error) {
      throw error.response?.data || error;
    }
  },

  // Marcar lección como completada
  completeLesson: async (lessonId) => {
    try {
      const response = await api.patch(`/lessons/${lessonId}/complete`);
      return response.data;
    } catch (error) {
      throw error.response?.data || error;
    }
  },

  // Obtener progreso del curso
  getCourseProgress: async (courseId) => {
    try {
      const response = await api.get(`/courses/${courseId}/progress`);
      return response.data;
    } catch (error) {
      throw error.response?.data || error;
    }
  },
};

export default api;
