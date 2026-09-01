import { rest } from './api';

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
  deleteUser: async (id) => {
    await rest.delete(`/users?id=eq.${id}`);
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

  // --- Inscripciones (gestión admin) ---
  // Obtener todas las inscripciones con datos de estudiante y curso
  getAllEnrollments: async () => {
    const { data } = await rest.get(
      '/enrollments?select=*,student:users!student_id(id,first_name,last_name,email),course:courses(id,title,category,duration_hours,is_published)&order=enrollment_date.desc'
    );
    return data;
  },

  // Inscripciones de un estudiante específico
  getStudentEnrollments: async (studentId) => {
    const { data } = await rest.get(
      `/enrollments?student_id=eq.${studentId}&select=*,course:courses(id,title,category,duration_hours,is_published)&order=enrollment_date.desc`
    );
    return data;
  },

  // Otorgar/inscribir un curso a un estudiante (admin)
  grantCourse: async (studentId, courseId) => {
    // Verificar si ya existe
    const { data: existing } = await rest.get(
      `/enrollments?student_id=eq.${studentId}&course_id=eq.${courseId}&select=id`
    );
    if (existing.length) {
      throw { message: 'El estudiante ya está inscrito en este curso' };
    }
    const { data } = await rest.post('/enrollments', {
      student_id: studentId,
      course_id: courseId,
      status: 'enrolled',
      progress_percentage: 0,
    });
    return data[0];
  },

  // Quitar/desinscribir un curso de un estudiante (admin)
  revokeCourse: async (enrollmentId) => {
    await rest.delete(`/enrollments?id=eq.${enrollmentId}`);
  },

  // --- Certificados (Administración) ---
  getAllCertificates: async () => {
    const { data } = await rest.get(
      '/certificates?select=*,student:users!student_id(first_name,last_name,curp,ocupacion,puesto,company_name,company_rfc),course:courses(id,title,duration_hours,category)&order=issued_date.desc'
    );
    return data;
  },

  // --- Órdenes / Pagos ---
  getAllOrders: async () => {
    const { data } = await rest.get(
      '/orders?select=*,student:users!student_id(first_name,last_name,nombres,apellido_paterno,apellido_materno,email),course:courses(id,title)&order=created_at.desc'
    );
    return data;
  },

  // --- Reportes básicos ---
  getReports: async () => {
    const [{ data: users }, { data: courses }, { data: enrollments }, { data: certificates }, { data: orders }] = await Promise.all([
      rest.get('/users?select=id,role'),
      rest.get('/courses?select=id,is_published,price'),
      rest.get('/enrollments?select=id,status,progress_percentage'),
      rest.get('/certificates?select=id'),
      rest.get('/orders?select=id,amount,status'),
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
      totalOrders: orders.length,
      totalRevenue: orders.filter((o) => o.status === 'paid').reduce((s, o) => s + parseFloat(o.amount || 0), 0),
    };
  },
};
