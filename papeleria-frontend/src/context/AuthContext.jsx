import { createContext, useState, useContext } from 'react';
import api from '../api/axios';

const AuthContext = createContext();

export const AuthProvider = ({ children }) => {
    const [user, setUser] = useState(null);
    const [token, setToken] = useState(localStorage.getItem('token'));
    const [loading, setLoading] = useState(false);

    const login = async (email, password) => {
        setLoading(true);
        try {
            const response = await api.post('/auth/login', { email, password });
            const { token, usuario } = response.data.data;
            localStorage.setItem('token', token);
            setToken(token);
            setUser(usuario);
            return { success: true };
        } catch (error) {
            return { 
                success: false, 
                message: error.response?.data?.message || 'Error al iniciar sesión' 
            };
        } finally {
            setLoading(false);
        }
    };

    const logout = () => {
        localStorage.removeItem('token');
        setToken(null);
        setUser(null);
    };

    return (
        <AuthContext.Provider value={{ user, token, login, logout, loading }}>
            {children}
        </AuthContext.Provider>
    );
};

export const useAuth = () => useContext(AuthContext);