import pool from '../config/database';

export interface DetalleVenta {
    producto_id: string;
    cantidad: number;
    precio_unitario: number;
}

export interface VentaInput {
    usuario_id: string;
    cliente_nombre?: string;
    cliente_telefono?: string;
    metodo_pago: 'EFECTIVO' | 'TARJETA' | 'TRANSFERENCIA';
    detalles: DetalleVenta[];
}

export class VentaModel {
    static async registrarVenta(ventaData: VentaInput): Promise<any> {
        const connection = await pool.getConnection();
        
        try {
            await connection.beginTransaction();

            // Calcular totales
            let subtotal = 0;
            for (const detalle of ventaData.detalles) {
                subtotal += detalle.cantidad * detalle.precio_unitario;
            }
            const iva = subtotal * 0.16;
            const total = subtotal + iva;

            // 1. Insertar venta
            const [ventaResult]: any = await connection.execute(
                `INSERT INTO ventas (id, usuario_id, cliente_nombre, cliente_telefono, subtotal, iva, total, metodo_pago)
                 VALUES (UUID(), ?, ?, ?, ?, ?, ?, ?)`,
                [
                    ventaData.usuario_id,
                    ventaData.cliente_nombre || null,
                    ventaData.cliente_telefono || null,
                    subtotal,
                    iva,
                    total,
                    ventaData.metodo_pago
                ]
            );

            // Obtener el ID de la venta creada
            const [ventaIdResult]: any = await connection.execute(
                `SELECT id FROM ventas WHERE id = LAST_INSERT_ID()`
            );
            const ventaId = ventaIdResult[0].id;

            // 2. Insertar detalles y actualizar stock
            for (const detalle of ventaData.detalles) {
                // Insertar detalle
                await connection.execute(
                    `INSERT INTO detalles_venta (venta_id, producto_id, cantidad, precio_unitario)
                     VALUES (?, ?, ?, ?)`,
                    [ventaId, detalle.producto_id, detalle.cantidad, detalle.precio_unitario]
                );

                // Actualizar stock (restar)
                await connection.execute(
                    `UPDATE productos 
                     SET stock_actual = stock_actual - ? 
                     WHERE id = ? AND stock_actual >= ?`,
                    [detalle.cantidad, detalle.producto_id, detalle.cantidad]
                );

                // Registrar movimiento de inventario (SALIDA)
                await connection.execute(
                    `INSERT INTO movimientos_inventario 
                     (producto_id, usuario_id, tipo_movimiento, cantidad, precio_unitario, referencia)
                     VALUES (?, ?, 'VENTA', ?, ?, ?)`,
                    [
                        detalle.producto_id,
                        ventaData.usuario_id,
                        -detalle.cantidad,
                        detalle.precio_unitario,
                        `VENTA-${ventaId.substring(0, 8)}`
                    ]
                );
            }

            await connection.commit();
            return { ventaId, subtotal, iva, total };

        } catch (error) {
            await connection.rollback();
            throw error;
        } finally {
            connection.release();
        }
    }
}