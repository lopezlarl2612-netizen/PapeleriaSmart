import { useEffect, useState } from 'react';
import { useAuth } from '../context/AuthContext';
import api from '../api/axios';
import Navbar from '../components/Navbar';

const Dashboard = () => {
    const { user } = useAuth();
    const [reportes, setReportes] = useState(null);
    const [loading, setLoading] = useState(true);

    useEffect(() => {
        const fetchReportes = async () => {
            try {
                const response = await api.get('/reportes/dashboard');
                setReportes(response.data.data);
            } catch (error) {
                console.error('Error al cargar reportes:', error);
            } finally {
                setLoading(false);
            }
        };
        fetchReportes();
    }, []);

    const totalMovimientos = reportes?.movimientos_mensuales?.reduce(
        (acc, m) => acc + m.numero_movimientos, 
        0
    ) || 0;

    return (
        <div className="min-h-screen bg-gray-50">
            <Navbar />

            <div className="max-w-7xl mx-auto px-4 py-8">
                <h2 className="text-3xl font-bold text-gray-800 mb-6">📊 Dashboard</h2>

                {loading ? (
                    <div className="text-center py-12">Cargando reportes...</div>
                ) : (
                    <>
                        <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-6">
                            <div className="bg-white p-6 rounded-xl shadow">
                                <h3 className="text-lg font-semibold text-gray-700">⚠️ Stock Crítico</h3>
                                <p className="text-3xl font-bold text-red-500">
                                    {reportes?.stock_critico?.length || 0}
                                </p>
                                <p className="text-sm text-gray-500">Productos por debajo del mínimo</p>
                            </div>

                            <div className="bg-white p-6 rounded-xl shadow">
                                <h3 className="text-lg font-semibold text-gray-700">🏆 Más Vendidos</h3>
                                <p className="text-3xl font-bold text-green-500">
                                    {reportes?.top_productos?.length || 0}
                                </p>
                                <p className="text-sm text-gray-500">Productos con más ventas</p>
                            </div>

                            <div className="bg-white p-6 rounded-xl shadow">
                                <h3 className="text-lg font-semibold text-gray-700">📦 Movimientos</h3>
                                <p className="text-3xl font-bold text-blue-500">
                                    {totalMovimientos}
                                </p>
                                <p className="text-sm text-gray-500">Movimientos este mes</p>
                            </div>

                            <div className="bg-white p-6 rounded-xl shadow">
                                <h3 className="text-lg font-semibold text-gray-700">📚 Total Productos</h3>
                                <p className="text-3xl font-bold text-purple-500">
                                    {reportes?.rotacion_abc?.length || 0}
                                </p>
                                <p className="text-sm text-gray-500">Productos en inventario</p>
                            </div>
                        </div>

                        {reportes?.stock_critico?.length > 0 && (
                            <div className="mt-8 bg-white p-6 rounded-xl shadow">
                                <h3 className="text-xl font-bold text-gray-800 mb-4">⚠️ Productos con Stock Crítico</h3>
                                <div className="overflow-x-auto">
                                    <table className="w-full">
                                        <thead className="bg-red-50">
                                            <tr>
                                                <th className="px-4 py-2 text-left">Producto</th>
                                                <th className="px-4 py-2 text-left">Categoría</th>
                                                <th className="px-4 py-2 text-left">Stock Actual</th>
                                                <th className="px-4 py-2 text-left">Mínimo</th>
                                                <th className="px-4 py-2 text-left">Faltante</th>
                                            </tr>
                                        </thead>
                                        <tbody>
                                            {reportes.stock_critico.map((item) => (
                                                <tr key={item.id} className="border-t">
                                                    <td className="px-4 py-2">{item.producto}</td>
                                                    <td className="px-4 py-2">{item.categoria}</td>
                                                    <td className="px-4 py-2 font-bold text-red-500">{item.stock_actual}</td>
                                                    <td className="px-4 py-2">{item.stock_minimo}</td>
                                                    <td className="px-4 py-2">{item.faltante}</td>
                                                </tr>
                                            ))}
                                        </tbody>
                                    </table>
                                </div>
                            </div>
                        )}
                    </>
                )}
            </div>
        </div>
    );
};

export default Dashboard;