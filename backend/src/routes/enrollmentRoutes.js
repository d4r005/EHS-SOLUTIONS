import express from 'express';
import { enroll, getMyEnrollments, getEnrollment } from '../controllers/enrollmentController.js';
import { authMiddleware } from '../middleware/auth.js';

const router = express.Router();

// Todas las rutas requieren autenticación
router.post('/', authMiddleware, enroll);
router.get('/', authMiddleware, getMyEnrollments);
router.get('/:id', authMiddleware, getEnrollment);

export default router;
