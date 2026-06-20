import { Request, Response } from 'express';
import { UsuarioModel } from '../models/usuario.model';

export class UsuarioController {
    static async getAll(req: Request, res: Response) {
        try {
            const usuarios = await UsuarioModel.getAll();
            res.json({
                success: true,
                data: usuarios,
                total: usuarios.length
            });
        } catch (error) {
            res.status(500).json({
                success: false,
                message: 'Error al obtener usuarios',
                error: error instanceof Error ? error.message : 'Unknown error'
            });
        }
    }

    static async update(req: Request, res: Response) {
        try {
            const { id } = req.params;
            const { nombre_completo, telefono, rol_id, esta_activo } = req.body;

            const result = await UsuarioModel.update(id, {
                nombre_completo,
                telefono,
                rol_id,
                esta_activo
            });

            if (result.affectedRows === 0) {
                return res.status(404).json({
                    success: false,
                    message: 'Usuario no encontrado'
                });
            }

            res.json({
                success: true,
                message: 'Usuario actualizado correctamente'
            });

        } catch (error) {
            res.status(500).json({
                success: false,
                message: 'Error al actualizar usuario',
                error: error instanceof Error ? error.message : 'Unknown error'
            });
        }
    }

    static async delete(req: Request, res: Response) {
        try {
            const { id } = req.params;

            const result = await UsuarioModel.delete(id);

            if (result.affectedRows === 0) {
                return res.status(404).json({
                    success: false,
                    message: 'Usuario no encontrado'
                });
            }

            res.json({
                success: true,
                message: 'Usuario desactivado correctamente'
            });

        } catch (error) {
            res.status(500).json({
                success: false,
                message: 'Error al desactivar usuario',
                error: error instanceof Error ? error.message : 'Unknown error'
            });
        }
    }
}