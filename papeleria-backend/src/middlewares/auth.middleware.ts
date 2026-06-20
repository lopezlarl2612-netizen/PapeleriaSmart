import { Request, Response, NextFunction } from 'express';
import jwt from 'jsonwebtoken';

export interface AuthRequest extends Request {
    user?: any;
}

export const authenticate = (req: AuthRequest, res: Response, next: NextFunction) => {
    const token = req.headers.authorization?.split(' ')[1];

    if (!token) {
        return res.status(401).json({
            success: false,
            message: 'Token no proporcionado'
        });
    }

    try {
        const decoded = jwt.verify(token, process.env.JWT_SECRET || 'mi_clave_secreta_super_segura_123');
        req.user = decoded;
        next();
    } catch (error) {
        return res.status(403).json({
            success: false,
            message: 'Token inválido o expirado'
        });
    }
};