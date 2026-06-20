import { Request, Response } from 'express';
import bcrypt from 'bcryptjs';
import jwt from 'jsonwebtoken';
import { UsuarioModel } from '../models/usuario.model';

export class AuthController {
    static async login(req: Request, res: Response) {
        try {
            const { email, password } = req.body;

            if (!email || !password) {
                return res.status(400).json({
                    success: false,
                    message: 'Email y contraseña son requeridos'
                });
            }

            const usuario = await UsuarioModel.findByEmail(email);

            if (!usuario) {
                return res.status(401).json({
                    success: false,
                    message: 'Credenciales inválidas'
                });
            }

            const passwordValida = await bcrypt.compare(password, usuario.password_hash);

            if (!passwordValida) {
                return res.status(401).json({
                    success: false,
                    message: 'Credenciales inválidas'
                });
            }

            const token = jwt.sign(
                { 
                    id: usuario.id, 
                    email: usuario.email, 
                    rol: usuario.rol_nombre 
                },
                process.env.JWT_SECRET || 'mi_clave_secreta_super_segura_123',
                { expiresIn: '24h' }
            );

            res.json({
                success: true,
                message: 'Login exitoso',
                data: {
                    token,
                    usuario: {
                        id: usuario.id,
                        email: usuario.email,
                        nombre_completo: usuario.nombre_completo,
                        rol: usuario.rol_nombre
                    }
                }
            });

        } catch (error) {
            res.status(500).json({
                success: false,
                message: 'Error al iniciar sesión',
                error: error instanceof Error ? error.message : 'Unknown error'
            });
        }
    }

    static async register(req: Request, res: Response) {
        try {
            const { email, password, nombre_completo, rol_id, telefono } = req.body;

            // Verificar si el usuario ya existe
            const existe = await UsuarioModel.findByEmail(email);
            if (existe) {
                return res.status(400).json({
                    success: false,
                    message: 'El email ya está registrado'
                });
            }

            const result = await UsuarioModel.create({
                email,
                password,
                nombre_completo,
                rol_id: rol_id || 1,
                telefono
            });

            res.status(201).json({
                success: true,
                message: 'Usuario creado exitosamente',
                data: { id: result.insertId }
            });

        } catch (error) {
            res.status(500).json({
                success: false,
                message: 'Error al crear usuario',
                error: error instanceof Error ? error.message : 'Unknown error'
            });
        }
    }

    static async getMe(req: any, res: Response) {
        try {
            const usuario = await UsuarioModel.findByEmail(req.user.email);
            if (!usuario) {
                return res.status(404).json({
                    success: false,
                    message: 'Usuario no encontrado'
                });
            }

            res.json({
                success: true,
                data: {
                    id: usuario.id,
                    email: usuario.email,
                    nombre_completo: usuario.nombre_completo,
                    rol: usuario.rol_nombre
                }
            });

        } catch (error) {
            res.status(500).json({
                success: false,
                message: 'Error al obtener datos del usuario'
            });
        }
    }
}