import { Router } from 'express';
import { ReporteController } from '../controllers/reporte.controller';

const router = Router();

router.get('/stock-critico', ReporteController.getStockCritico);
router.get('/top-productos', ReporteController.getTopProductos);
router.get('/movimientos-mensuales', ReporteController.getMovimientosMensuales);
router.get('/rotacion-abc', ReporteController.getRotacionABC);
router.get('/dashboard', ReporteController.getDashboard);
router.get('/movimientos', ReporteController.getMovimientos);  // ← NUEVA LÍNEA

export default router;