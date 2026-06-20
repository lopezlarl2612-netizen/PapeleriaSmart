import { Link } from 'react-router-dom';
import { useAuth } from '../context/AuthContext';

const Navbar = () => {
    const { user, logout } = useAuth();

    return (
        <nav className="bg-indigo-600 shadow-lg p-4">
            <div className="flex flex-wrap justify-between items-center gap-4">
                <Link to="/" className="text-black font-bold text-xl">📚 PapeleriaSmart</Link>
                <div className="flex flex-wrap items-center gap-6">
                    <Link to="/" className="text-black hover:text-gray-700">Dashboard</Link>
                    <Link to="/productos" className="text-black hover:text-gray-700">Productos</Link>
                    <Link to="/ventas" className="text-black hover:text-gray-700">Ventas</Link>
                    <Link to="/reportes" className="text-black hover:text-gray-700">Reportes</Link>
                    <Link to="/movimientos" className="text-black hover:text-gray-700">Movimientos</Link>
                    {user?.rol === 'ADMIN' && (
                        <Link to="/usuarios" className="text-black hover:text-gray-700">Usuarios</Link>
                    )}
                </div>
                <div className="flex items-center gap-4">
                    <span className="text-black">👤 {user?.nombre_completo}</span>
                    <button onClick={logout} className="bg-red-500 text-white px-4 py-2 rounded hover:bg-red-600">Salir</button>
                </div>
            </div>
        </nav>
    );
};

export default Navbar;