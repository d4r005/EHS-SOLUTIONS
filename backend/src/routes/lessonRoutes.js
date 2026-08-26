import express from 'express';
import { getLessons, getLessonById, createLesson, updateLesson, deleteLesson, completeLesson } from '../controllers/lessonController.js';
import { authMiddleware, instructorMiddleware } from '../middleware/auth.js';

const router = express.Router();

// Rutas públicas
router.get('/', getLessons);
router.get('/:id', authMiddleware, getLessonById);

// Rutas protegidas
router.post('/', authMiddleware, instructorMiddleware, createLesson);
router.put('/:id', authMiddleware, instructorMiddleware, updateLesson);
router.delete('/:id', authMiddleware, instructorMiddleware, deleteLesson);
router.patch('/:id/complete', authMiddleware, completeLesson);

export default router;
