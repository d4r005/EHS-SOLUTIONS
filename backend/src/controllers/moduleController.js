import pool from '../config/database.js';

// GET /modules?course_id=X - Listar módulos con lecciones
export const getModules = async (req, res) => {
  try {
    const { course_id } = req.query;

    let query = `
      SELECT m.*, 
        COALESCE(json_agg(
          json_build_object(
            'id', l.id, 'title', l.title, 'description', l.description,
            'content_type', l.content_type, 'content_url', l.content_url,
            'video_url', l.video_url, 'document_url', l.document_url,
            'duration_minutes', l.duration_minutes, 'order_index', l.order_index,
            'is_required', l.is_required
          ) ORDER BY l.order_index
        ) FILTER (WHERE l.id IS NOT NULL), '[]') as lessons
      FROM modules m
      LEFT JOIN lessons l ON l.module_id = m.id
    `;
    const params = [];
    let paramIndex = 1;

    if (course_id) {
      query += ` WHERE m.course_id = $${paramIndex++}`;
      params.push(course_id);
    }

    query += ' GROUP BY m.id ORDER BY m.order_index';

    const result = await pool.query(query, params);
    res.json({ success: true, modules: result.rows });
  } catch (error) {
    console.error('Error al obtener módulos:', error);
    res.status(500).json({ success: false, message: 'Error al obtener módulos' });
  }
};

// POST /modules - Crear módulo
export const createModule = async (req, res) => {
  try {
    const { course_id, title, description, order_index } = req.body;

    if (!course_id || !title) {
      return res.status(400).json({ success: false, message: 'course_id y title son requeridos' });
    }

    const result = await pool.query(`
      INSERT INTO modules (course_id, title, description, order_index, created_at, updated_at)
      VALUES ($1, $2, $3, $4, NOW(), NOW()) RETURNING *
    `, [course_id, title, description, order_index || 0]);

    res.status(201).json({ success: true, module: result.rows[0] });
  } catch (error) {
    console.error('Error al crear módulo:', error);
    res.status(500).json({ success: false, message: 'Error al crear módulo' });
  }
};

// PUT /modules/:id - Actualizar módulo
export const updateModule = async (req, res) => {
  try {
    const { id } = req.params;
    const { title, description, order_index } = req.body;

    const result = await pool.query(`
      UPDATE modules SET
        title = COALESCE($1, title),
        description = COALESCE($2, description),
        order_index = COALESCE($3, order_index),
        updated_at = NOW()
      WHERE id = $4 RETURNING *
    `, [title, description, order_index, id]);

    if (result.rows.length === 0) {
      return res.status(404).json({ success: false, message: 'Módulo no encontrado' });
    }

    res.json({ success: true, module: result.rows[0] });
  } catch (error) {
    console.error('Error al actualizar módulo:', error);
    res.status(500).json({ success: false, message: 'Error al actualizar módulo' });
  }
};

// DELETE /modules/:id - Eliminar módulo
export const deleteModule = async (req, res) => {
  try {
    const { id } = req.params;
    await pool.query('DELETE FROM modules WHERE id = $1', [id]);
    res.json({ success: true, message: 'Módulo eliminado' });
  } catch (error) {
    console.error('Error al eliminar módulo:', error);
    res.status(500).json({ success: false, message: 'Error al eliminar módulo' });
  }
};
