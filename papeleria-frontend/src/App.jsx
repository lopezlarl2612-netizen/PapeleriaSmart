import { BrowserRouter, Routes, Route, Navigate } from 'react-router-dom';
import { AuthProvider, useAuth } from './context/AuthContext';
import Login from './pages/Login';
import Dashboard from './pages/Dashboard';
import Productos from './pages/Productos';
import Ventas from './pages/Ventas';
import Reportes from './pages/Reportes';
import Movimientos from './pages/Movimientos';
import './output.css';

const ProtectedRoute = ({ children }) => {
    const { token } = useAuth();
    return token ? children : <Navigate to="/login" />;
};

function App() {
    return (
        <AuthProvider>
            <BrowserRouter>
                <Routes>
                    <Route path="/login" element={<Login />} />
                    <Route path="/" element={<ProtectedRoute><Dashboard /></ProtectedRoute>} />
                    <Route path="/productos" element={<ProtectedRoute><Productos /></ProtectedRoute>} />
                    <Route path="/ventas" element={<ProtectedRoute><Ventas /></ProtectedRoute>} />
                    <Route path="/reportes" element={<ProtectedRoute><Reportes /></ProtectedRoute>} />
                    <Route path="/movimientos" element={<ProtectedRoute><Movimientos /></ProtectedRoute>} />
                    <Route path="*" element={<Navigate to="/" />} />
                </Routes>
            </BrowserRouter>
        </AuthProvider>
    );
}

export default App;