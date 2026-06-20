import express, { Request, Response } from 'express';
import cors from 'cors';
import helmet from 'helmet';
import dotenv from 'dotenv';
import productoRoutes from './routes/producto.routes';
import ventaRoutes from './routes/venta.routes';
import reporteRoutes from './routes/reporte.routes';
import authRoutes from './routes/auth.routes';      // ← VERIFICA QUE ESTÉ
import usuarioRoutes from './routes/usuario.routes'; // ← VERIFICA QUE ESTÉ
import { authenticate } from './middlewares/auth.middleware';

dotenv.config();

const app = express();
const PORT = process.env.PORT || 3000;

app.use(cors());
app.use(helmet());
app.use(express.json());
app.use(express.urlencoded({ extended: true }));

// ============================================================
// RUTAS PÚBLICAS
// ============================================================

app.use('/api/auth', authRoutes);  // ← VERIFICA QUE ESTÉ

app.get('/health', (req: Request, res: Response) => {
    res.json({ status: 'healthy', uptime: process.uptime(), timestamp: new Date().toISOString() });
});

app.get('/', (req: Request, res: Response) => {
    res.json({ message: '✅ API de PapeleriaSmart funcionando correctamente', status: 'OK', timestamp: new Date().toISOString() });
});

// ============================================================
// RUTAS PROTEGIDAS
// ============================================================

app.use('/api/productos', authenticate, productoRoutes);
app.use('/api/ventas', authenticate, ventaRoutes);
app.use('/api/reportes', authenticate, reporteRoutes);
app.use('/api/usuarios', authenticate, usuarioRoutes);

// ============================================================
// MANEJO DE ERRORES
// ============================================================

app.use((req: Request, res: Response) => {
    res.status(404).json({ success: false, message: 'Ruta no encontrada' });
});

app.listen(PORT, () => {
    console.log(`🚀 Servidor corriendo en http://localhost:${PORT}`);
    console.log(`📊 Health check: http://localhost:${PORT}/health`);
    console.log(`🔐 Login: POST http://localhost:${PORT}/api/auth/login`);
    console.log(`📦 Productos: GET http://localhost:${PORT}/api/productos (requiere token)`);
    console.log(`💰 Ventas: POST http://localhost:${PORT}/api/ventas (requiere token)`);
    console.log(`📈 Reportes: http://localhost:${PORT}/api/reportes/dashboard (requiere token)`);
});