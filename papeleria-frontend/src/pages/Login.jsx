import { useState } from 'react';
import { useAuth } from '../context/AuthContext';

const Login = () => {
    const [email, setEmail] = useState('ogonzava@papeleriasmart.com');
    const [password, setPassword] = useState('Password123!');
    const [error, setError] = useState('');
    const [loading, setLoading] = useState(false);
    const { login } = useAuth();

    const handleSubmit = async (e) => {
        e.preventDefault();
        console.log('🔵 Botón presionado');
        console.log('📧 Email:', email);
        console.log('🔒 Password:', password);
        
        setError('');
        setLoading(true);
        
        try {
            const result = await login(email, password);
            console.log('📦 Resultado del login:', result);
            
            if (result.success) {
                console.log('✅ Login exitoso, redirigiendo...');
                window.location.href = '/';
            } else {
                setError(result.message || 'Credenciales inválidas');
                console.log('❌ Error:', result.message);
            }
        } catch (err) {
            console.error('💥 Error en handleSubmit:', err);
            setError('Error al conectar con el servidor');
        } finally {
            setLoading(false);
        }
    };

    return (
        <div className="min-h-screen flex items-center justify-center bg-gradient-to-br from-indigo-100 via-purple-100 to-pink-100">
            <div className="bg-white/80 backdrop-blur-sm p-8 rounded-3xl shadow-2xl w-full max-w-md border border-white/50">
                <div className="text-center mb-8">
                    <div className="text-6xl mb-4">📚</div>
                    <h1 className="text-4xl font-bold bg-gradient-to-r from-indigo-600 to-purple-600 bg-clip-text text-transparent">
                        PapeleriaSmart
                    </h1>
                    <p className="text-gray-500 mt-2">Sistema de Gestión de Inventario</p>
                </div>

                {error && (
                    <div className="bg-red-100 border border-red-400 text-red-700 px-4 py-3 rounded-xl mb-4">
                        ❌ {error}
                    </div>
                )}

                <form onSubmit={handleSubmit}>
                    <div className="mb-4">
                        <label className="block text-gray-700 font-medium mb-2">📧 Email</label>
                        <input
                            type="email"
                            value={email}
                            onChange={(e) => setEmail(e.target.value)}
                            className="w-full px-4 py-3 border border-gray-300 rounded-xl focus:outline-none focus:ring-2 focus:ring-indigo-400 transition-all"
                            required
                        />
                    </div>

                    <div className="mb-6">
                        <label className="block text-gray-700 font-medium mb-2">🔒 Contraseña</label>
                        <input
                            type="password"
                            value={password}
                            onChange={(e) => setPassword(e.target.value)}
                            className="w-full px-4 py-3 border border-gray-300 rounded-xl focus:outline-none focus:ring-2 focus:ring-indigo-400 transition-all"
                            required
                        />
                    </div>

                    <button
                        type="submit"
                        disabled={loading}
                        className="w-full bg-gradient-to-r from-indigo-600 to-purple-600 text-white py-3 rounded-xl font-semibold hover:from-indigo-700 hover:to-purple-700 transition-all duration-200 transform hover:scale-[1.02] disabled:opacity-50"
                    >
                        {loading ? 'Cargando...' : '🚀 Iniciar Sesión'}
                    </button>
                </form>

                <div className="mt-6 pt-6 border-t border-gray-200">
                    <p className="text-center text-sm text-gray-500">Usuarios de prueba:</p>
                    <div className="mt-2 space-y-1">
                        <p className="text-xs text-center text-gray-400">📊 ogonzava@papeleriasmart.com / Password123!</p>
                        <p className="text-xs text-center text-gray-400">💻 aibasi@papeleriasmart.com / Password123!</p>
                    </div>
                </div>
            </div>
        </div>
    );
};

export default Login;