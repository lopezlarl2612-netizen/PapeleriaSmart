import { Router } from 'express';
import { UsuarioController } from '../controllers/usuario.controller';
import { authenticate } from '../middlewares/auth.middleware';

const router = Router();

// Todas las rutas requieren autenticación
router.use(authenticate);

router.get('/', UsuarioController.getAll);
router.put('/:id', UsuarioController.update);
router.delete('/:id', UsuarioController.delete);

export default router;