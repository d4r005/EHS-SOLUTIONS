import pool from '../config/database.js';

// GET /lessons?module_id=X - Listar lecciones de un módulo
export const getLessons = async (req, res) => {
  try {
    const { module_id } = req.query;

    if (!module_id) {
      return res.status(400).json({ success: false, message: 'module_id es requerido' });
    }

    const result = await pool.query(`
      SELECT * FROM lessons WHERE module_id = $1 ORDER BY order_index
    `, [module_id]);

    res.json({ success: true, lessons: result.rows });
  } catch (error) {
    console.error('Error al obtener lecciones:', error);
    res.status(500).json({ success: false, message: 'Error al obtener lecciones' });
  }
};

// GET /lessons/:id - Detalle de una lección
export const getLessonById = async (req, res) => {
  try {
    const { id } = req.params;

    const result = await pool.query('SELECT * FROM lessons WHERE id = $1', [id]);

    if (result.rows.length === 0) {
      return res.status(404).json({ success: false, message: 'Lección no encontrada' });
    }

    let lessonProgress = null;
    if (req.user) {
      const progress = await pool.query(
        'SELECT * FROM lesson_progress WHERE student_id = $1 AND lesson_id = $2',
        [req.user.id, id]
      );
      lessonProgress = progress.rows[0] || null;
    }

    res.json({
      success: true,
      lesson: result.rows[0],
      progress: lessonProgress
    });
  } catch (error) {
    console.error('Error al obtener lección:', error);
    res.status(500).json({ success: false, message: 'Error al obtener lección' });
  }
};

// POST /lessons - Crear lección
export const createLesson = async (req, res) => {
  try {
    const {
      module_id, title, description, content_type = 'text',
      content_url, video_url, document_url, content, duration_minutes, order_index, is_required = true
    } = req.body;

    if (!module_id || !title) {
      return res.status(400).json({ success: false, message: 'module_id y title son requeridos' });
    }

    const result = await pool.query(`
      INSERT INTO lessons (module_id, title, description, content_type, content_url,
        video_url, document_url, content, duration_minutes, order_index, is_required, created_at, updated_at)
      VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9, $10, $11, NOW(), NOW()) RETURNING *
    `, [module_id, title, description, content_type, content_url,
        video_url, document_url, content, duration_minutes, order_index || 0, is_required]);

    res.status(201).json({ success: true, lesson: result.rows[0] });
  } catch (error) {
    console.error('Error al crear lección:', error);
    res.status(500).json({ success: false, message: 'Error al crear lección' });
  }
};

// PUT /lessons/:id - Actualizar lección
export const updateLesson = async (req, res) => {
  try {
    const { id } = req.params;
    const {
      title, description, content_type, content_url,
      video_url, document_url, content, duration_minutes, order_index, is_required
    } = req.body;

    const result = await pool.query(`
      UPDATE lessons SET
        title = COALESCE($1, title),
        description = COALESCE($2, description),
        content_type = COALESCE($3, content_type),
        content_url = COALESCE($4, content_url),
        video_url = COALESCE($5, video_url),
        document_url = COALESCE($6, document_url),
        content = COALESCE($7, content),
        duration_minutes = COALESCE($8, duration_minutes),
        order_index = COALESCE($9, order_index),
        is_required = COALESCE($10, is_required),
        updated_at = NOW()
      WHERE id = $11 RETURNING *
    `, [title, description, content_type, content_url,
        video_url, document_url, content, duration_minutes, order_index, is_required, id]);

    if (result.rows.length === 0) {
      return res.status(404).json({ success: false, message: 'Lección no encontrada' });
    }

    res.json({ success: true, lesson: result.rows[0] });
  } catch (error) {
    console.error('Error al actualizar lección:', error);
    res.status(500).json({ success: false, message: 'Error al actualizar lección' });
  }
};

// DELETE /lessons/:id - Eliminar lección
export const deleteLesson = async (req, res) => {
  try {
    const { id } = req.params;
    await pool.query('DELETE FROM lessons WHERE id = $1', [id]);
    res.json({ success: true, message: 'Lección eliminada' });
  } catch (error) {
    console.error('Error al eliminar lección:', error);
    res.status(500).json({ success: false, message: 'Error al eliminar lección' });
  }
};

// PATCH /lessons/:id/complete - Marcar lección como completada
export const completeLesson = async (req, res) => {
  try {
    const { id } = req.params;

    const lesson = await pool.query('SELECT * FROM lessons WHERE id = $1', [id]);
    if (lesson.rows.length === 0) {
      return res.status(404).json({ success: false, message: 'Lección no encontrada' });
    }

    const result = await pool.query(`
      INSERT INTO lesson_progress (student_id, lesson_id, is_completed, completion_date, time_spent_minutes)
      VALUES ($1, $2, true, NOW(), 0)
      ON CONFLICT (student_id, lesson_id)
      DO UPDATE SET is_completed = true, completion_date = NOW()
      RETURNING *
    `, [req.user.id, id]);

    // Actualizar progreso de inscripción
    const moduleResult = await pool.query('SELECT course_id FROM modules WHERE id = $1', [lesson.rows[0].module_id]);
    if (moduleResult.rows.length > 0) {
      const courseId = moduleResult.rows[0].course_id;

      const totalLessons = await pool.query(`
        SELECT COUNT(*) FROM lessons l
        JOIN modules m ON l.module_id = m.id
        WHERE m.course_id = $1
      `, [courseId]);

      const completedLessons = await pool.query(`
        SELECT COUNT(*) FROM lesson_progress lp
        JOIN lessons l ON lp.lesson_id = l.id
        JOIN modules m ON l.module_id = m.id
        WHERE m.course_id = $1 AND lp.student_id = $2 AND lp.is_completed = true
      `, [courseId, req.user.id]);

      const total = parseInt(totalLessons.rows[0].count);
      const completed = parseInt(completedLessons.rows[0].count);
      const percentage = total > 0 ? Math.round((completed / total) * 100 * 100) / 100 : 0;
      const status = percentage === 100 ? 'completed' : 'in_progress';

      await pool.query(`
        UPDATE enrollments SET progress_percentage = $1, status = $2,
          completion_date = CASE WHEN $1 = 100 THEN NOW() ELSE completion_date END
        WHERE student_id = $3 AND course_id = $4
      `, [percentage, status, req.user.id, courseId]);
    }

    res.json({ success: true, message: 'Lección marcada como completada', progress: result.rows[0] });
  } catch (error) {
    console.error('Error al completar lección:', error);
    res.status(500).json({ success: false, message: 'Error al completar lección' });
  }
};
