import express from 'express';
import { getModules, createModule, updateModule, deleteModule } from '../controllers/moduleController.js';
import { authMiddleware, instructorMiddleware } from '../middleware/auth.js';

const router = express.Router();

// Rutas públicas (ver módulos)
router.get('/', getModules);

// Rutas protegidas
router.post('/', authMiddleware, instructorMiddleware, createModule);
router.put('/:id', authMiddleware, instructorMiddleware, updateModule);
router.delete('/:id', authMiddleware, instructorMiddleware, deleteModule);

export default router;
