import pool from '../config/database.js';

// POST /enrollments - Inscribirse a un curso
export const enroll = async (req, res) => {
  try {
    const { course_id } = req.body;

    if (!course_id) {
      return res.status(400).json({ success: false, message: 'course_id es requerido' });
    }

    const course = await pool.query('SELECT * FROM courses WHERE id = $1 AND is_published = true', [course_id]);
    if (course.rows.length === 0) {
      return res.status(404).json({ success: false, message: 'Curso no encontrado o no publicado' });
    }

    const existing = await pool.query(
      'SELECT * FROM enrollments WHERE student_id = $1 AND course_id = $2',
      [req.user.id, course_id]
    );
    if (existing.rows.length > 0) {
      return res.status(409).json({ success: false, message: 'Ya estás inscrito en este curso' });
    }

    const result = await pool.query(`
      INSERT INTO enrollments (student_id, course_id, enrollment_date, status, progress_percentage)
      VALUES ($1, $2, NOW(), 'enrolled', 0) RETURNING *
    `, [req.user.id, course_id]);

    res.status(201).json({
      success: true,
      message: 'Inscripción exitosa',
      enrollment: result.rows[0]
    });
  } catch (error) {
    console.error('Error al inscribir:', error);
    res.status(500).json({ success: false, message: 'Error al inscribirse' });
  }
};

// GET /enrollments - Obtener mis inscripciones
export const getMyEnrollments = async (req, res) => {
  try {
    const result = await pool.query(`
      SELECT e.*, c.title, c.short_description, c.thumbnail_url, c.category,
        c.difficulty_level, c.duration_hours,
        u.first_name as instructor_first_name, u.last_name as instructor_last_name
      FROM enrollments e
      JOIN courses c ON e.course_id = c.id
      JOIN users u ON c.instructor_id = u.id
      WHERE e.student_id = $1
      ORDER BY e.enrollment_date DESC
    `, [req.user.id]);

    res.json({ success: true, enrollments: result.rows });
  } catch (error) {
    console.error('Error al obtener inscripciones:', error);
    res.status(500).json({ success: false, message: 'Error al obtener inscripciones' });
  }
};

// GET /enrollments/:id - Detalle de una inscripción
export const getEnrollment = async (req, res) => {
  try {
    const { id } = req.params;

    const result = await pool.query(`
      SELECT e.*, c.title, c.description, c.short_description,
        u.first_name as instructor_first_name, u.last_name as instructor_last_name
      FROM enrollments e
      JOIN courses c ON e.course_id = c.id
      JOIN users u ON c.instructor_id = u.id
      WHERE e.id = $1 AND e.student_id = $2
    `, [id, req.user.id]);

    if (result.rows.length === 0) {
      return res.status(404).json({ success: false, message: 'Inscripción no encontrada' });
    }

    res.json({ success: true, enrollment: result.rows[0] });
  } catch (error) {
    console.error('Error al obtener inscripción:', error);
    res.status(500).json({ success: false, message: 'Error al obtener inscripción' });
  }
};
