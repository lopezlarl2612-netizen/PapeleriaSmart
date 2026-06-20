import { Router } from 'express';
import { VentaController } from '../controllers/venta.controller';

const router = Router();

router.post('/', VentaController.registrarVenta);

export default router;