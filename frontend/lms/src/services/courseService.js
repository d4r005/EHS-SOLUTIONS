import axios from 'axios';

// ============================================
// EHS Solutions - Frontend API Service
// Usa Supabase REST API (PostgREST) directamente
// Sin backend propio necesario
// ============================================

const SUPABASE_URL = import.meta.env.VITE_SUPABASE_URL || 'https://tsqlpjliqslgzookdqvg.supabase.co';
const SUPABASE_KEY = import.meta.env.VITE_SUPABASE_KEY;

// Cliente PostgREST
const rest = axios.create({
  baseURL: `${SUPABASE_URL}/rest/v1`,
  headers: {
    apikey: SUPABASE_KEY,
    'Content-Type': 'application/json',
  },
});

// Interceptor: agregar token de auth automáticamente
rest.interceptors.request.use((config) => {
  const token = localStorage.getItem('token');
  if (token) config.headers.Authorization = `Bearer ${token}`;
  return config;
});

export const courseService = {
  // Listar cursos publicados
  getCourses: async (filters = {}) => {
    try {
      let query = '/courses?select=*,instructor:users!instructor_id(first_name,last_name),modules(id,lessons(id))&is_published=eq.true';
      if (filters.category) query += `&category=eq.${filters.category}`;
      if (filters.difficulty_level) query += `&difficulty_level=eq.${filters.difficulty_level}`;
      if (filters.search) query += `&or=(title.ilike.%${filters.search}%,description.ilike.%${filters.search}%)`;
      query += '&order=created_at.desc';

      const { data } = await rest.get(query);
      const courses = data.map((c) => ({
        ...c,
        instructor_first_name: c.instructor?.first_name,
        instructor_last_name: c.instructor?.last_name,
        module_count: c.modules?.length || 0,
        lesson_count: c.modules?.reduce((s, m) => s + (m.lessons?.length || 0), 0) || 0,
        instructor: undefined,
        modules: undefined,
      }));
      return { success: true, courses };
    } catch (error) {
      throw error.response?.data || error;
    }
  },

  // Detalle de un curso con módulos y lecciones
  getCourseById: async (id) => {
    try {
      const { data } = await rest.get(
        `/courses?id=eq.${id}&select=*,instructor:users!instructor_id(first_name,last_name),modules(id,title,description,order_index,lessons(id,title,description,content_type,content_url,video_url,document_url,duration_minutes,order_index,is_required))`
      );
      if (!data.length) return { success: false, message: 'Curso no encontrado' };

      const course = data[0];
      // Ordenar módulos y lecciones
      course.modules = (course.modules || []).sort((a, b) => a.order_index - b.order_index);
      course.modules.forEach((m) => {
        m.lessons = (m.lessons || []).sort((a, b) => a.order_index - b.order_index);
      });
      course.instructor_first_name = course.instructor?.first_name;
      course.instructor_last_name = course.instructor?.last_name;
      course.module_count = course.modules.length;
      course.lesson_count = course.modules.reduce((s, m) => s + m.lessons.length, 0);
      course.instructor = undefined;

      // Verificar inscripción
      const userId = localStorage.getItem('userId');
      if (userId && userId !== '0') {
        const { data: enr } = await rest.get(
          `/enrollments?student_id=eq.${userId}&course_id=eq.${id}&select=*`
        );
        course.enrollment = enr[0] || null;
      } else {
        course.enrollment = null;
      }

      return { success: true, course };
    } catch (error) {
      throw error.response?.data || error;
    }
  },

  // Inscribirse a un curso
  enrollCourse: async (courseId) => {
    try {
      const userId = parseInt(localStorage.getItem('userId'));
      if (!userId) throw { message: 'No autenticado' };

      const { data: existing } = await rest.get(
        `/enrollments?student_id=eq.${userId}&course_id=eq.${courseId}&select=id`
      );
      if (existing.length) throw { message: 'Ya estás inscrito en este curso' };

      const { data } = await rest.post('/enrollments', {
        student_id: userId,
        course_id: parseInt(courseId),
        status: 'enrolled',
        progress_percentage: 0,
      });
      return { success: true, message: 'Inscripción exitosa', enrollment: data[0] };
    } catch (error) {
      throw error.response?.data || error;
    }
  },

  // Obtener mis cursos inscritos
  getMyCourses: async () => {
    try {
      const userId = localStorage.getItem('userId');
      if (!userId || userId === '0') return { success: true, enrollments: [] };

      const { data } = await rest.get(
        `/enrollments?student_id=eq.${userId}&select=*,course:courses(id,title,short_description,thumbnail_url,category,difficulty_level,duration_hours)&order=enrollment_date.desc`
      );
      const enrollments = data.map((e) => ({
        ...e,
        title: e.course?.title,
        short_description: e.course?.short_description,
        thumbnail_url: e.course?.thumbnail_url,
        category: e.course?.category,
        difficulty_level: e.course?.difficulty_level,
        duration_hours: e.course?.duration_hours,
      }));
      return { success: true, enrollments };
    } catch (error) {
      throw error.response?.data || error;
    }
  },

  // Obtener módulos de un curso
  getModules: async (courseId) => {
    try {
      const { data } = await rest.get(
        `/modules?course_id=eq.${courseId}&select=*,lessons(*)&order=order_index`
      );
      const modules = data.map((m) => ({
        ...m,
        lessons: (m.lessons || []).sort((a, b) => a.order_index - b.order_index),
      }));
      return { success: true, modules };
    } catch (error) {
      throw error.response?.data || error;
    }
  },

  // Obtener lecciones de un módulo
  getLessons: async (moduleId) => {
    try {
      const { data } = await rest.get(
        `/lessons?module_id=eq.${moduleId}&select=*&order=order_index`
      );
      return { success: true, lessons: data };
    } catch (error) {
      throw error.response?.data || error;
    }
  },

  // Marcar lección como completada
  completeLesson: async (lessonId) => {
    try {
      const userId = parseInt(localStorage.getItem('userId'));
      if (!userId) throw { message: 'No autenticado' };

      // Upsert lesson_progress
      await rest.post(
        '/lesson_progress',
        {
          student_id: userId,
          lesson_id: parseInt(lessonId),
          is_completed: true,
          completion_date: new Date().toISOString(),
          time_spent_minutes: 0,
        },
        { headers: { Prefer: 'resolution=merge-duplicates' }, params: { on_conflict: 'student_id,lesson_id' } }
      );

      // Actualizar progreso de inscripción
      const { data: lesson } = await rest.get(`/lessons?id=eq.${lessonId}&select=module_id`);
      if (lesson.length) {
        const { data: mod } = await rest.get(`/modules?id=eq.${lesson[0].module_id}&select=course_id`);
        if (mod.length) {
          const courseId = mod[0].course_id;
          const { data: modules } = await rest.get(`/modules?course_id=eq.${courseId}&select=id`);
          const moduleIds = modules.map((m) => m.id);

          const { data: allLessons } = await rest.get(
            `/lessons?module_id=in.(${moduleIds.join(',')})&select=id`
          );
          const lessonIds = allLessons.map((l) => l.id);

          let completedCount = 0;
          if (lessonIds.length) {
            const { data: completed } = await rest.get(
              `/lesson_progress?student_id=eq.${userId}&is_completed=eq.true&lesson_id=in.(${lessonIds.join(',')})&select=id`
            );
            completedCount = completed.length;
          }

          const total = allLessons.length;
          const pct = total > 0 ? Math.round((completedCount / total) * 10000) / 100 : 0;
          const status = pct === 100 ? 'completed' : 'in_progress';

          await rest.patch(`/enrollments?student_id=eq.${userId}&course_id=eq.${courseId}`, {
            progress_percentage: pct,
            status,
            completion_date: pct === 100 ? new Date().toISOString() : null,
          });
        }
      }

      return { success: true, message: 'Lección completada' };
    } catch (error) {
      throw error.response?.data || error;
    }
  },

  // Obtener progreso del curso
  getCourseProgress: async (courseId) => {
    try {
      const userId = parseInt(localStorage.getItem('userId'));
      if (!userId) return { success: false, message: 'No autenticado' };

      const { data: enr } = await rest.get(
        `/enrollments?student_id=eq.${userId}&course_id=eq.${courseId}&select=*`
      );
      if (!enr.length) return { success: false, message: 'No estás inscrito en este curso' };

      const { data: modules } = await rest.get(`/modules?course_id=eq.${courseId}&select=id`);
      const moduleIds = modules.map((m) => m.id);

      const { data: allLessons } = await rest.get(
        `/lessons?module_id=in.(${moduleIds.join(',')})&select=id`
      );
      const lessonIds = allLessons.map((l) => l.id);

      let completedCount = 0;
      if (lessonIds.length) {
        const { data: completed } = await rest.get(
          `/lesson_progress?student_id=eq.${userId}&is_completed=eq.true&lesson_id=in.(${lessonIds.join(',')})&select=id`
        );
        completedCount = completed.length;
      }

      const total = allLessons.length;
      const pct = total > 0 ? Math.round((completedCount / total) * 100) : 0;

      return {
        success: true,
        progress: {
          enrollment: enr[0],
          total_lessons: total,
          completed_lessons: completedCount,
          percentage: pct,
        },
      };
    } catch (error) {
      throw error.response?.data || error;
    }
  },
};

export default rest;
