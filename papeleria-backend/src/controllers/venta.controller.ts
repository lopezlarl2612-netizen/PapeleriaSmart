import { Request, Response } from 'express';
import { VentaModel } from '../models/venta.model';

export class VentaController {
    static async registrarVenta(req: Request, res: Response) {
        try {
            const ventaData = req.body;
            
            // Validaciones básicas
            if (!ventaData.usuario_id) {
                return res.status(400).json({
                    success: false,
                    message: 'Falta usuario_id'
                });
            }

            if (!ventaData.detalles || ventaData.detalles.length === 0) {
                return res.status(400).json({
                    success: false,
                    message: 'La venta debe tener al menos un producto'
                });
            }

            const resultado = await VentaModel.registrarVenta(ventaData);

            res.status(201).json({
                success: true,
                message: 'Venta registrada exitosamente',
                data: resultado
            });

        } catch (error) {
            console.error('Error al registrar venta:', error);
            res.status(500).json({
                success: false,
                message: 'Error al registrar la venta',
                error: error instanceof Error ? error.message : 'Unknown error'
            });
        }
    }
}