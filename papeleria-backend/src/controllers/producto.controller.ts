import { Request, Response } from 'express';
import { ProductoModel } from '../models/producto.model';

export class ProductoController {
    static async getAll(req: Request, res: Response) {
        try {
            const productos = await ProductoModel.getAll();
            res.json({
                success: true,
                data: productos,
                total: productos.length
            });
        } catch (error) {
            console.error('Error al obtener productos:', error);
            res.status(500).json({
                success: false,
                message: 'Error al obtener productos',
                error: error instanceof Error ? error.message : 'Unknown error'
            });
        }
    }
}