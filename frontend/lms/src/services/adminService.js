import axios from 'axios';

// ============================================
// EHS Solutions - Panel de administración
// Usuarios, cursos y reportes básicos
// ============================================

const SUPABASE_URL = import.meta.env.VITE_SUPABASE_URL || 'https://tsqlpjliqslgzookdqvg.supabase.co';
const SUPABASE_KEY = import.meta.env.VITE_SUPABASE_KEY;

const rest = axios.create({
  baseURL: `${SUPABASE_URL}/rest/v1`,
  headers: { apikey: SUPABASE_KEY, 'Content-Type': 'application/json' },
});

rest.interceptors.request.use((config) => {
  const token = localStorage.getItem('token');
  if (token) config.headers.Authorization = `Bearer ${token}`;
  return config;
});

export const adminService = {
  // --- Usuarios ---
  getUsers: async () => {
    const { data } = await rest.get('/users?select=id,first_name,last_name,email,role,is_active,created_at&order=created_at.desc');
    return data;
  },
  updateUserRole: async (id, role) => {
    await rest.patch(`/users?id=eq.${id}`, { role });
  },
  toggleUserActive: async (id, isActive) => {
    await rest.patch(`/users?id=eq.${id}`, { is_active: isActive });
  },

  // --- Cursos (todos, no solo publicados) ---
  getAllCourses: async () => {
    const { data } = await rest.get(
      '/courses?select=*,instructor:users!instructor_id(first_name,last_name)&order=created_at.desc'
    );
    return data.map((c) => ({
      ...c,
      instructor_first_name: c.instructor?.first_name,
      instructor_last_name: c.instructor?.last_name,
    }));
  },
  togglePublish: async (id, isPublished) => {
    await rest.patch(`/courses?id=eq.${id}`, { is_published: isPublished });
  },
  deleteCourse: async (id) => {
    await rest.delete(`/courses?id=eq.${id}`);
  },

  // --- Reportes básicos ---
  getReports: async () => {
    const [{ data: users }, { data: courses }, { data: enrollments }, { data: certificates }] = await Promise.all([
      rest.get('/users?select=id,role'),
      rest.get('/courses?select=id,is_published,price'),
      rest.get('/enrollments?select=id,status,progress_percentage'),
      rest.get('/certificates?select=id'),
    ]);

    return {
      totalStudents: users.filter((u) => u.role === 'student').length,
      totalInstructors: users.filter((u) => u.role === 'instructor').length,
      totalCourses: courses.length,
      publishedCourses: courses.filter((c) => c.is_published).length,
      totalEnrollments: enrollments.length,
      completedEnrollments: enrollments.filter((e) => e.status === 'completed').length,
      totalCertificates: certificates.length,
      paidCourses: courses.filter((c) => c.price > 0).length,
    };
  },
};
