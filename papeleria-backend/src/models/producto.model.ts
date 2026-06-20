import pool from '../config/database';
import { RowDataPacket } from 'mysql2';

export interface Producto extends RowDataPacket {
    id: string;
    nombre: string;
    categoria: string;
    precio_venta: number;
    stock_actual: number;
    stock_minimo: number;
}

export class ProductoModel {
    static async getAll(): Promise<Producto[]> {
        const [rows] = await pool.query<Producto[]>(`
            SELECT 
                p.id,
                p.nombre AS producto,
                c.nombre AS categoria,
                p.precio_venta,
                p.stock_actual,
                p.stock_minimo
            FROM productos p
            INNER JOIN categorias c ON p.categoria_id = c.id
            WHERE p.esta_activo = TRUE
            ORDER BY p.nombre
        `);
        return rows;
    }
}