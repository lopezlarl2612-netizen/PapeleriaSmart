import Navbar from '../components/Navbar';

const Productos = () => {
    return (
        <div className="min-h-screen bg-gray-50">
            <Navbar />
            <div className="max-w-7xl mx-auto px-4 py-8">
                <h1 className="text-3xl font-bold text-gray-800">📦 Productos</h1>
                <p className="text-gray-600 mt-4">Aquí irá la lista de productos (próximamente)</p>
            </div>
        </div>
    );
};

export default Productos;