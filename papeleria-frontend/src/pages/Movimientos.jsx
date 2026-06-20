import { useEffect, useState } from 'react';
import Navbar from '../components/Navbar';
import api from '../api/axios';

const Movimientos = () => {
    const [movimientos, setMovimientos] = useState([]);
    const [loading, setLoading] = useState(true);

    useEffect(() => {
        const fetchMovimientos = async () => {
            try {
                const response = await api.get('/reportes/movimientos');
                setMovimientos(response.data.data);
            } catch (error) {
                console.error('Error al cargar movimientos:', error);
            } finally {
                setLoading(false);
            }
        };
        fetchMovimientos();
    }, []);

    return (
        <div className="min-h-screen bg-gray-50">
            <Navbar />
            <div className="max-w-7xl mx-auto px-4 py-8">
                <h1 className="text-3xl font-bold text-gray-800 mb-6">📦 Movimientos de Inventario</h1>

                {loading ? (
                    <div className="text-center py-12">Cargando movimientos...</div>
                ) : (
                    <div className="bg-white rounded-xl shadow overflow-hidden">
                        <table className="w-full">
                            <thead className="bg-indigo-50">
                                <tr>
                                    <th className="px-4 py-3 text-left text-sm font-semibold text-gray-600">Producto</th>
                                    <th className="px-4 py-3 text-left text-sm font-semibold text-gray-600">Tipo</th>
                                    <th className="px-4 py-3 text-left text-sm font-semibold text-gray-600">Cantidad</th>
                                    <th className="px-4 py-3 text-left text-sm font-semibold text-gray-600">Precio</th>
                                    <th className="px-4 py-3 text-left text-sm font-semibold text-gray-600">Usuario</th>
                                    <th className="px-4 py-3 text-left text-sm font-semibold text-gray-600">Fecha</th>
                                </tr>
                            </thead>
                            <tbody className="divide-y divide-gray-200">
                                {movimientos.map((mov) => (
                                    <tr key={mov.id} className="hover:bg-gray-50">
                                        <td className="px-4 py-3">{mov.producto}</td>
                                        <td className="px-4 py-3">
                                            <span className={`px-2 py-1 rounded text-xs font-semibold ${
                                                mov.tipo_movimiento === 'COMPRA' ? 'bg-green-100 text-green-700' :
                                                mov.tipo_movimiento === 'VENTA' ? 'bg-red-100 text-red-700' :
                                                'bg-yellow-100 text-yellow-700'
                                            }`}>
                                                {mov.tipo_movimiento}
                                            </span>
                                        </td>
                                        <td className="px-4 py-3 font-bold">{mov.cantidad}</td>
                                        <td className="px-4 py-3">${mov.precio_unitario}</td>
                                        <td className="px-4 py-3">{mov.usuario}</td>
                                        <td className="px-4 py-3 text-sm text-gray-500">
                                            {new Date(mov.fecha).toLocaleString()}
                                        </td>
                                    </tr>
                                ))}
                            </tbody>
                        </table>
                    </div>
                )}
            </div>
        </div>
    );
};

export default Movimientos;