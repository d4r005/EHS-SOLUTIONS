import pool from '../config/database.js';

// GET /courses - Listar cursos publicados con filtros opcionales
export const getCourses = async (req, res) => {
  try {
    const { category, difficulty_level, search } = req.query;
    let query = `
      SELECT c.*, u.first_name, u.last_name,
        (SELECT COUNT(*) FROM modules m WHERE m.course_id = c.id) as module_count,
        (SELECT COUNT(*) FROM lessons l 
         JOIN modules m ON l.module_id = m.id 
         WHERE m.course_id = c.id) as lesson_count
      FROM courses c
      JOIN users u ON c.instructor_id = u.id
      WHERE c.is_published = true
    `;
    const params = [];
    let paramIndex = 1;

    if (category) {
      query += ` AND c.category = $${paramIndex++}`;
      params.push(category);
    }
    if (difficulty_level) {
      query += ` AND c.difficulty_level = $${paramIndex++}`;
      params.push(difficulty_level);
    }
    if (search) {
      query += ` AND (c.title ILIKE $${paramIndex} OR c.description ILIKE $${paramIndex})`;
      params.push(`%${search}%`);
      paramIndex++;
    }

    query += ' ORDER BY c.created_at DESC';

    const result = await pool.query(query, params);
    res.json({ success: true, courses: result.rows });
  } catch (error) {
    console.error('Error al obtener cursos:', error);
    res.status(500).json({ success: false, message: 'Error al obtener cursos' });
  }
};

// GET /courses/:id - Detalle de un curso
export const getCourseById = async (req, res) => {
  try {
    const { id } = req.params;

    const courseResult = await pool.query(`
      SELECT c.*, u.first_name as instructor_first_name, u.last_name as instructor_last_name,
        (SELECT COUNT(*) FROM modules m WHERE m.course_id = c.id) as module_count,
        (SELECT COUNT(*) FROM lessons l 
         JOIN modules m ON l.module_id = m.id 
         WHERE m.course_id = c.id) as lesson_count
      FROM courses c
      JOIN users u ON c.instructor_id = u.id
      WHERE c.id = $1
    `, [id]);

    if (courseResult.rows.length === 0) {
      return res.status(404).json({ success: false, message: 'Curso no encontrado' });
    }

    const modulesResult = await pool.query(`
      SELECT m.*, 
        COALESCE(json_agg(
          json_build_object(
            'id', l.id, 'title', l.title, 'description', l.description,
            'content_type', l.content_type, 'duration_minutes', l.duration_minutes,
            'order_index', l.order_index, 'video_url', l.video_url, 'document_url', l.document_url
          ) ORDER BY l.order_index
        ) FILTER (WHERE l.id IS NOT NULL), '[]') as lessons
      FROM modules m
      LEFT JOIN lessons l ON l.module_id = m.id
      WHERE m.course_id = $1
      GROUP BY m.id
      ORDER BY m.order_index
    `, [id]);

    const course = courseResult.rows[0];
    course.modules = modulesResult.rows;

    if (req.user) {
      const enrollment = await pool.query(
        'SELECT * FROM enrollments WHERE student_id = $1 AND course_id = $2',
        [req.user.id, id]
      );
      course.enrollment = enrollment.rows[0] || null;
    }

    res.json({ success: true, course });
  } catch (error) {
    console.error('Error al obtener curso:', error);
    res.status(500).json({ success: false, message: 'Error al obtener curso' });
  }
};

// POST /courses - Crear curso (instructor/admin)
export const createCourse = async (req, res) => {
  try {
    const {
      title, description, short_description, category,
      thumbnail_url, price = 0, duration_hours, difficulty_level, is_published = false
    } = req.body;

    if (!title) {
      return res.status(400).json({ success: false, message: 'El título es requerido' });
    }

    const result = await pool.query(`
      INSERT INTO courses (title, description, short_description, instructor_id, category,
        thumbnail_url, price, duration_hours, difficulty_level, is_published, created_at, updated_at)
      VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9, $10, NOW(), NOW())
      RETURNING *
    `, [title, description, short_description, req.user.id, category,
        thumbnail_url, price, duration_hours, difficulty_level, is_published]);

    res.status(201).json({ success: true, course: result.rows[0] });
  } catch (error) {
    console.error('Error al crear curso:', error);
    res.status(500).json({ success: false, message: 'Error al crear curso' });
  }
};

// PUT /courses/:id - Actualizar curso
export const updateCourse = async (req, res) => {
  try {
    const { id } = req.params;
    const {
      title, description, short_description, category,
      thumbnail_url, price, duration_hours, difficulty_level, is_published
    } = req.body;

    if (req.user.role === 'instructor') {
      const owner = await pool.query('SELECT instructor_id FROM courses WHERE id = $1', [id]);
      if (owner.rows.length === 0) {
        return res.status(404).json({ success: false, message: 'Curso no encontrado' });
      }
      if (owner.rows[0].instructor_id !== req.user.id) {
        return res.status(403).json({ success: false, message: 'No tienes permiso' });
      }
    }

    const result = await pool.query(`
      UPDATE courses SET
        title = COALESCE($1, title),
        description = COALESCE($2, description),
        short_description = COALESCE($3, short_description),
        category = COALESCE($4, category),
        thumbnail_url = COALESCE($5, thumbnail_url),
        price = COALESCE($6, price),
        duration_hours = COALESCE($7, duration_hours),
        difficulty_level = COALESCE($8, difficulty_level),
        is_published = COALESCE($9, is_published),
        updated_at = NOW()
      WHERE id = $10 RETURNING *
    `, [title, description, short_description, category, thumbnail_url,
        price, duration_hours, difficulty_level, is_published, id]);

    if (result.rows.length === 0) {
      return res.status(404).json({ success: false, message: 'Curso no encontrado' });
    }

    res.json({ success: true, course: result.rows[0] });
  } catch (error) {
    console.error('Error al actualizar curso:', error);
    res.status(500).json({ success: false, message: 'Error al actualizar curso' });
  }
};

// DELETE /courses/:id - Eliminar curso
export const deleteCourse = async (req, res) => {
  try {
    const { id } = req.params;

    if (req.user.role === 'instructor') {
      const owner = await pool.query('SELECT instructor_id FROM courses WHERE id = $1', [id]);
      if (owner.rows.length === 0) {
        return res.status(404).json({ success: false, message: 'Curso no encontrado' });
      }
      if (owner.rows[0].instructor_id !== req.user.id) {
        return res.status(403).json({ success: false, message: 'No tienes permiso' });
      }
    }

    await pool.query('DELETE FROM courses WHERE id = $1', [id]);
    res.json({ success: true, message: 'Curso eliminado' });
  } catch (error) {
    console.error('Error al eliminar curso:', error);
    res.status(500).json({ success: false, message: 'Error al eliminar curso' });
  }
};

// GET /courses/:id/progress - Progreso del estudiante
export const getCourseProgress = async (req, res) => {
  try {
    const { id } = req.params;

    const enrollment = await pool.query(
      'SELECT * FROM enrollments WHERE student_id = $1 AND course_id = $2',
      [req.user.id, id]
    );

    if (enrollment.rows.length === 0) {
      return res.status(404).json({ success: false, message: 'No estás inscrito en este curso' });
    }

    const totalLessons = await pool.query(`
      SELECT COUNT(*) FROM lessons l
      JOIN modules m ON l.module_id = m.id
      WHERE m.course_id = $1
    `, [id]);

    const completedLessons = await pool.query(`
      SELECT COUNT(*) FROM lesson_progress lp
      JOIN lessons l ON lp.lesson_id = l.id
      JOIN modules m ON l.module_id = m.id
      WHERE m.course_id = $1 AND lp.student_id = $2 AND lp.is_completed = true
    `, [id, req.user.id]);

    const total = parseInt(totalLessons.rows[0].count);
    const completed = parseInt(completedLessons.rows[0].count);
    const percentage = total > 0 ? Math.round((completed / total) * 100) : 0;

    res.json({
      success: true,
      progress: {
        enrollment: enrollment.rows[0],
        total_lessons: total,
        completed_lessons: completed,
        percentage
      }
    });
  } catch (error) {
    console.error('Error al obtener progreso:', error);
    res.status(500).json({ success: false, message: 'Error al obtener progreso' });
  }
};
