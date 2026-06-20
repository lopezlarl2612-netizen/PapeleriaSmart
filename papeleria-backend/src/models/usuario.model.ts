import pool from '../config/database';
import bcrypt from 'bcryptjs';
import { RowDataPacket } from 'mysql2';

export interface Usuario extends RowDataPacket {
    id: string;
    email: string;
    nombre_completo: string;
    rol_id: number;
    rol_nombre?: string;
    esta_activo: boolean;
}

export class UsuarioModel {
    static async findByEmail(email: string): Promise<Usuario | null> {
        const [rows] = await pool.query<Usuario[]>(`
            SELECT u.*, r.nombre as rol_nombre 
            FROM usuarios u
            INNER JOIN roles r ON u.rol_id = r.id
            WHERE u.email = ? AND u.esta_activo = TRUE
        `, [email]);
        return rows.length > 0 ? rows[0] : null;
    }

    static async create(usuarioData: any): Promise<any> {
        const { email, password, nombre_completo, rol_id, telefono } = usuarioData;
        const hashedPassword = await bcrypt.hash(password, 10);
        
        const [result]: any = await pool.execute(
            `INSERT INTO usuarios (id, email, password_hash, nombre_completo, rol_id, telefono)
             VALUES (UUID(), ?, ?, ?, ?, ?)`,
            [email, hashedPassword, nombre_completo, rol_id, telefono || null]
        );
        return result;
    }

    static async getAll(): Promise<Usuario[]> {
        const [rows] = await pool.query<Usuario[]>(`
            SELECT u.id, u.email, u.nombre_completo, u.rol_id, r.nombre as rol_nombre, u.esta_activo
            FROM usuarios u
            INNER JOIN roles r ON u.rol_id = r.id
            ORDER BY u.nombre_completo
        `);
        return rows;
    }

    static async update(id: string, data: any): Promise<any> {
        const { nombre_completo, telefono, rol_id, esta_activo } = data;
        const [result]: any = await pool.execute(
            `UPDATE usuarios 
             SET nombre_completo = ?, telefono = ?, rol_id = ?, esta_activo = ?
             WHERE id = ?`,
            [nombre_completo, telefono, rol_id, esta_activo, id]
        );
        return result;
    }

    static async delete(id: string): Promise<any> {
        const [result]: any = await pool.execute(
            `UPDATE usuarios SET esta_activo = FALSE WHERE id = ?`,
            [id]
        );
        return result;
    }
}