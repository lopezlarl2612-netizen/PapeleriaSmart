import { Request, Response } from 'express';
import pool from '../config/database';

export class ReporteController {
    // 1. Stock crítico
    static async getStockCritico(req: Request, res: Response) {
        try {
            const [rows] = await pool.query(`
                SELECT * FROM vista_stock_critico
            `);
            res.json({
                success: true,
                data: rows,
                total: Array.isArray(rows) ? rows.length : 0
            });
        } catch (error) {
            res.status(500).json({
                success: false,
                message: 'Error al obtener stock crítico',
                error: error instanceof Error ? error.message : 'Unknown error'
            });
        }
    }

    // 2. Top productos más vendidos
    static async getTopProductos(req: Request, res: Response) {
        try {
            const [rows] = await pool.query(`
                SELECT * FROM vista_top_productos
            `);
            res.json({
                success: true,
                data: rows,
                total: Array.isArray(rows) ? rows.length : 0
            });
        } catch (error) {
            res.status(500).json({
                success: false,
                message: 'Error al obtener top productos',
                error: error instanceof Error ? error.message : 'Unknown error'
            });
        }
    }

    // 3. Movimientos mensuales
    static async getMovimientosMensuales(req: Request, res: Response) {
        try {
            const [rows] = await pool.query(`
                SELECT * FROM vista_movimientos_mensuales
            `);
            res.json({
                success: true,
                data: rows,
                total: Array.isArray(rows) ? rows.length : 0
            });
        } catch (error) {
            res.status(500).json({
                success: false,
                message: 'Error al obtener movimientos mensuales',
                error: error instanceof Error ? error.message : 'Unknown error'
            });
        }
    }

    // 4. Rotación ABC
    static async getRotacionABC(req: Request, res: Response) {
        try {
            const [rows] = await pool.query(`
                SELECT * FROM vista_rotacion_productos
            `);
            res.json({
                success: true,
                data: rows,
                total: Array.isArray(rows) ? rows.length : 0
            });
        } catch (error) {
            res.status(500).json({
                success: false,
                message: 'Error al obtener rotación ABC',
                error: error instanceof Error ? error.message : 'Unknown error'
            });
        }
    }

    // 5. Dashboard completo (todos los reportes en uno)
    static async getDashboard(req: Request, res: Response) {
        try {
            // Ejecutar todas las consultas en paralelo
            const [stockCritico, topProductos, movimientosMensuales, rotacionABC] = await Promise.all([
                pool.query(`SELECT * FROM vista_stock_critico`),
                pool.query(`SELECT * FROM vista_top_productos`),
                pool.query(`SELECT * FROM vista_movimientos_mensuales`),
                pool.query(`SELECT * FROM vista_rotacion_productos`)
            ]);

            res.json({
                success: true,
                data: {
                    stock_critico: stockCritico[0],
                    top_productos: topProductos[0],
                    movimientos_mensuales: movimientosMensuales[0],
                    rotacion_abc: rotacionABC[0]
                }
            });
        } catch (error) {
            res.status(500).json({
                success: false,
                message: 'Error al obtener dashboard',
                error: error instanceof Error ? error.message : 'Unknown error'
            });
        }
    }

    // 6. Listar todos los movimientos de inventario (para la página de movimientos)
    static async getMovimientos(req: Request, res: Response) {
        try {
            const [rows] = await pool.query(`
                SELECT 
                    mi.id,
                    p.nombre AS producto,
                    mi.tipo_movimiento,
                    mi.cantidad,
                    mi.precio_unitario,
                    mi.created_at AS fecha,
                    u.nombre_completo AS usuario
                FROM movimientos_inventario mi
                INNER JOIN productos p ON mi.producto_id = p.id
                INNER JOIN usuarios u ON mi.usuario_id = u.id
                ORDER BY mi.created_at DESC
                LIMIT 50
            `);
            res.json({
                success: true,
                data: rows,
                total: Array.isArray(rows) ? rows.length : 0
            });
        } catch (error) {
            res.status(500).json({
                success: false,
                message: 'Error al obtener movimientos',
                error: error instanceof Error ? error.message : 'Unknown error'
            });
        }
    }
}