import express from 'express';
import { getCourses, getCourseById, createCourse, updateCourse, deleteCourse, getCourseProgress } from '../controllers/courseController.js';
import { authMiddleware, instructorMiddleware } from '../middleware/auth.js';

const router = express.Router();

// Rutas públicas (sin auth)
router.get('/', getCourses);
router.get('/:id', authMiddleware, getCourseById);

// Rutas protegidas
router.post('/', authMiddleware, instructorMiddleware, createCourse);
router.put('/:id', authMiddleware, instructorMiddleware, updateCourse);
router.delete('/:id', authMiddleware, instructorMiddleware, deleteCourse);
router.get('/:id/progress', authMiddleware, getCourseProgress);

export default router;
