-- ============================================================
-- BASE DE DATOS: papeleria_smart
-- SISTEMA: Gestión de Inventario para Papelería
-- VERSIÓN: 2.0 DEFINITIVA (LIMPIA Y OPTIMIZADA)
-- ============================================================

-- ============================================================
-- 1. CREACIÓN DE BASE DE DATOS
-- ============================================================

CREATE DATABASE IF NOT EXISTS papeleria_smart
CHARACTER SET utf8mb4
COLLATE utf8mb4_unicode_ci;

USE papeleria_smart;

-- ============================================================
-- 2. TABLAS
-- ============================================================
-- ------------------------------------------------------------
-- 2.1 Tabla: roles
-- ------------------------------------------------------------
CREATE TABLE roles (
    id TINYINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    nombre VARCHAR(50) UNIQUE NOT NULL,
    descripcion TEXT,
    permisos JSON,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
) COMMENT 'Catálogo de roles';

-- ------------------------------------------------------------
-- 2.2 Tabla: usuarios
-- ------------------------------------------------------------
CREATE TABLE usuarios (
    id CHAR(36) PRIMARY KEY DEFAULT (UUID()),
    rol_id TINYINT UNSIGNED NOT NULL,
    email VARCHAR(255) UNIQUE NOT NULL,
    password_hash CHAR(60) NOT NULL,
    nombre_completo VARCHAR(100) NOT NULL,
    telefono VARCHAR(20) NULL,
    esta_activo BOOLEAN DEFAULT TRUE,
    ultimo_login TIMESTAMP NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (rol_id) REFERENCES roles(id),
    INDEX idx_usuario_rol (rol_id),
    INDEX idx_usuario_email (email)
) COMMENT 'Usuarios del sistema';

-- ------------------------------------------------------------
-- 2.3 Tabla: categorias
-- ------------------------------------------------------------
CREATE TABLE categorias (
    id SMALLINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    nombre VARCHAR(100) UNIQUE NOT NULL,
    descripcion TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
) COMMENT 'Categorías de productos';

-- ------------------------------------------------------------
-- 2.4 Tabla: proveedores
-- ------------------------------------------------------------
CREATE TABLE proveedores (
    id CHAR(36) PRIMARY KEY DEFAULT (UUID()),
    nombre VARCHAR(150) NOT NULL,
    rfc VARCHAR(20) NULL,
    telefono VARCHAR(20) NULL,
    email VARCHAR(150) NULL,
    direccion TEXT,
    esta_activo BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
) COMMENT 'Catálogo de proveedores';

-- ------------------------------------------------------------
-- 2.5 Tabla: productos
-- ------------------------------------------------------------
CREATE TABLE productos (
    id CHAR(36) PRIMARY KEY DEFAULT (UUID()),
    categoria_id SMALLINT UNSIGNED NOT NULL,
    proveedor_id CHAR(36) NULL,
    codigo_barras VARCHAR(50) UNIQUE NULL,
    nombre VARCHAR(150) NOT NULL,
    descripcion TEXT,
    precio_compra DECIMAL(10,2) NOT NULL,
    precio_venta DECIMAL(10,2) NOT NULL,
    stock_actual INT NOT NULL DEFAULT 0,
    stock_minimo INT DEFAULT 5,
    stock_maximo INT DEFAULT 100,
    unidad_medida ENUM('PIEZA', 'PAQUETE', 'RESMA', 'CAJA', 'KILO') DEFAULT 'PIEZA',
    imagen_url VARCHAR(255) NULL,
    esta_activo BOOLEAN DEFAULT TRUE,
    creado_por CHAR(36) NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (categoria_id) REFERENCES categorias(id),
    FOREIGN KEY (proveedor_id) REFERENCES proveedores(id),
    FOREIGN KEY (creado_por) REFERENCES usuarios(id),
    INDEX idx_producto_categoria (categoria_id),
    INDEX idx_producto_stock (stock_actual, stock_minimo),
    INDEX idx_producto_nombre (nombre),
    UNIQUE INDEX idx_codigo_barras (codigo_barras)
) COMMENT 'Catálogo de productos';

-- ------------------------------------------------------------
-- 2.6 Tabla: movimientos_inventario
-- ------------------------------------------------------------
CREATE TABLE movimientos_inventario (
    id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    producto_id CHAR(36) NOT NULL,
    usuario_id CHAR(36) NOT NULL,
    tipo_movimiento ENUM('COMPRA', 'VENTA', 'AJUSTE_ENTRADA', 'AJUSTE_SALIDA', 'DEVOLUCION') NOT NULL,
    cantidad INT NOT NULL,
    precio_unitario DECIMAL(10,2) NOT NULL,
    referencia VARCHAR(100) NULL,
    notas TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (producto_id) REFERENCES productos(id),
    FOREIGN KEY (usuario_id) REFERENCES usuarios(id),
    INDEX idx_movimiento_producto (producto_id),
    INDEX idx_movimiento_fecha (created_at)
) COMMENT 'Historial de movimientos de inventario';

-- ------------------------------------------------------------
-- 2.7 Tabla: ventas
-- ------------------------------------------------------------
CREATE TABLE ventas (
    id CHAR(36) PRIMARY KEY DEFAULT (UUID()),
    usuario_id CHAR(36) NOT NULL,
    cliente_nombre VARCHAR(150) NULL,
    cliente_telefono VARCHAR(20) NULL,
    subtotal DECIMAL(10,2) NOT NULL,
    iva DECIMAL(10,2) NOT NULL DEFAULT 0.16,
    total DECIMAL(10,2) NOT NULL,
    metodo_pago ENUM('EFECTIVO', 'TARJETA', 'TRANSFERENCIA') NOT NULL,
    fecha_venta TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (usuario_id) REFERENCES usuarios(id),
    INDEX idx_venta_fecha (fecha_venta)
) COMMENT 'Cabecera de ventas';

-- ------------------------------------------------------------
-- 2.8 Tabla: detalles_venta
-- ------------------------------------------------------------
CREATE TABLE detalles_venta (
    id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    venta_id CHAR(36) NOT NULL,
    producto_id CHAR(36) NOT NULL,
    cantidad INT NOT NULL,
    precio_unitario DECIMAL(10,2) NOT NULL,
    descuento DECIMAL(10,2) DEFAULT 0,
    FOREIGN KEY (venta_id) REFERENCES ventas(id) ON DELETE CASCADE,
    FOREIGN KEY (producto_id) REFERENCES productos(id),
    INDEX idx_detalle_venta (venta_id),
    INDEX idx_detalle_producto (producto_id)
) COMMENT 'Detalle de productos vendidos';

-- ============================================================
-- 3. ÍNDICES ADICIONALES
-- ============================================================
CREATE FULLTEXT INDEX ft_producto_nombre ON productos(nombre, descripcion);

-- ============================================================
-- 4. VISTAS PARA REPORTES
-- ============================================================
CREATE OR REPLACE VIEW vista_stock_critico AS
SELECT 
    p.id,
    p.nombre AS producto,
    p.stock_actual,
    p.stock_minimo,
    c.nombre AS categoria,
    (p.stock_minimo - p.stock_actual) AS faltante
FROM productos p
INNER JOIN categorias c ON p.categoria_id = c.id
WHERE p.stock_actual <= p.stock_minimo AND p.esta_activo = TRUE
ORDER BY faltante DESC;

CREATE OR REPLACE VIEW vista_top_productos AS
SELECT 
    p.id,
    p.nombre AS producto,
    c.nombre AS categoria,
    SUM(dv.cantidad) AS total_vendido,
    SUM(dv.cantidad * dv.precio_unitario) AS ingreso_total
FROM detalles_venta dv
INNER JOIN productos p ON dv.producto_id = p.id
INNER JOIN categorias c ON p.categoria_id = c.id
WHERE p.esta_activo = TRUE
GROUP BY p.id, p.nombre, c.nombre
ORDER BY total_vendido DESC
LIMIT 10;

CREATE OR REPLACE VIEW vista_movimientos_mensuales AS
SELECT 
    DATE_FORMAT(created_at, '%Y-%m') AS mes,
    tipo_movimiento,
    SUM(cantidad) AS total_cantidad,
    COUNT(*) AS numero_movimientos
FROM movimientos_inventario
GROUP BY mes, tipo_movimiento
ORDER BY mes DESC;

CREATE OR REPLACE VIEW vista_rotacion_productos AS
SELECT 
    p.id,
    p.nombre AS producto,
    c.nombre AS categoria,
    p.stock_actual,
    COALESCE(SUM(dv.cantidad), 0) AS total_vendido,
    CASE 
        WHEN COALESCE(SUM(dv.cantidad), 0) >= 100 THEN 'A - ALTA'
        WHEN COALESCE(SUM(dv.cantidad), 0) >= 50 THEN 'B - MEDIA'
        ELSE 'C - BAJA'
    END AS clasificacion_abc
FROM productos p
INNER JOIN categorias c ON p.categoria_id = c.id
LEFT JOIN detalles_venta dv ON p.id = dv.producto_id
WHERE p.esta_activo = TRUE
GROUP BY p.id, p.nombre, c.nombre, p.stock_actual
ORDER BY total_vendido DESC;

-- ============================================================
-- 5. DATOS DE PRUEBA
-- ============================================================
INSERT INTO roles (nombre, descripcion, permisos) VALUES
('ANALISTA', 'Andrea Huerta Alonzo - KPIs y análisis de datos', '{"inventario":"read", "reportes":"write"}'),
('DISENADOR', 'Fernando Gonzales Valdez - UI/UX y prototipado', '{"inventario":"read", "reportes":"read"}'),
('DESARROLLADOR', 'Leonardo Arturo Lopez Ramos - BD y API', '{"inventario":"write", "reportes":"write", "ventas":"write"}'),
('TESTER', 'Marco Magaña - Calidad y documentación', '{"inventario":"read", "reportes":"read", "ventas":"read"}');

INSERT INTO categorias (nombre, descripcion) VALUES
('CUADERNOS', 'Libretas, cuadernos profesionales y agendas'),
('LAPICEROS', 'Bolígrafos, plumones y marcadores'),
('PAPELERÍA FINA', 'Papel bond, cartulinas y cartoncillo'),
('OFICINA', 'Sellos, perforadoras y engrapadoras'),
('ARTÍCULOS ESCOLARES', 'Colores, pegamentos y tijeras'),
('TÓNER Y TINTAS', 'Cartuchos de tinta y tóner'),
('ARCHIVO', 'Carpetas, folders y organizadores');

INSERT INTO proveedores (nombre, rfc, telefono, email, direccion) VALUES
('Papelería Mayorista S.A.', 'PAPME123456', '555-123-4567', 'ventas@papeleriamayorista.com', 'Av. Principal #123, CDMX'),
('Distribuciones Escolares', 'DIESC789012', '555-234-5678', 'contacto@distribucionescolar.com', 'Calle Secundaria #456, CDMX'),
('Office Supplies México', 'OSMEX345678', '555-345-6789', 'info@officesupplies.mx', 'Boulevard Empresarial #789, CDMX'),
('Papel y Más', 'PYMAS901234', '555-456-7890', 'ventas@papelymas.com', 'Avenida Industrial #101, CDMX');

INSERT INTO usuarios (id, rol_id, email, password_hash, nombre_completo, telefono) VALUES
(UUID(), 1, 'ogonzava@papeleriasmart.com', '$2a$10$N9qo8uLOickgx2ZMRZoMyeIjZAgcfl7p92ldGxad68LJZdL17lhWy', 'Omar González Valdez', '555-111-1111'),
(UUID(), 2, 'alesilva@papeleriasmart.com', '$2a$10$N9qo8uLOickgx2ZMRZoMyeIjZAgcfl7p92ldGxad68LJZdL17lhWy', 'Alejandro Silva Aviña', '555-222-2222'),
(UUID(), 3, 'aibasi@papeleriasmart.com', '$2a$10$N9qo8uLOickgx2ZMRZoMyeIjZAgcfl7p92ldGxad68LJZdL17lhWy', 'Alyn Ibarra Cirilo', '555-333-3333'),
(UUID(), 4, 'alericoher@papeleriasmart.com', '$2a$10$N9qo8uLOickgx2ZMRZoMyeIjZAgcfl7p92ldGxad68LJZdL17lhWy', 'Alexandra Rico Hernandez', '555-444-4444');

INSERT INTO productos (categoria_id, codigo_barras, nombre, descripcion, precio_compra, precio_venta, stock_actual, stock_minimo, stock_maximo, unidad_medida, creado_por)
SELECT 1, '7501234567890', 'Cuaderno Profesional A5', 'Pasta dura, hojas rayadas', 35.00, 65.00, 45, 10, 80, 'PIEZA', id FROM usuarios WHERE email = 'ogonzava@papeleriasmart.com'
UNION ALL
SELECT 2, '7501234567891', 'Bolígrafo Retráctil Negro', 'Punta fina 0.7mm', 5.00, 12.00, 120, 20, 200, 'PIEZA', id FROM usuarios WHERE email = 'aibasi@papeleriasmart.com'
UNION ALL
SELECT 3, '7501234567892', 'Papel Bond Carta 75g', 'Resma 500 hojas', 80.00, 150.00, 25, 5, 50, 'RESMA', id FROM usuarios WHERE email = 'alesilva@papeleriasmart.com'
UNION ALL
SELECT 4, '7501234567893', 'Engrapadora Metálica', 'Capacidad 25 hojas', 45.00, 89.00, 15, 3, 30, 'PIEZA', id FROM usuarios WHERE email = 'alericoher@papeleriasmart.com'
UNION ALL
SELECT 5, '7501234567894', 'Juego de Colores 12 piezas', 'Colores de madera', 25.00, 45.00, 60, 15, 100, 'PIEZA', id FROM usuarios WHERE email = 'ogonzava@papeleriasmart.com'
UNION ALL
SELECT 1, '7501234567895', 'Agenda Ejecutiva 2026', 'Tapa dura, semana vista', 45.00, 89.00, 30, 8, 60, 'PIEZA', id FROM usuarios WHERE email = 'aibasi@papeleriasmart.com'
UNION ALL
SELECT 2, '7501234567896', 'Plumón Permanente Negro', 'Punta redonda, resistente al agua', 8.00, 18.00, 80, 15, 150, 'PIEZA', id FROM usuarios WHERE email = 'alesilva@papeleriasmart.com'
UNION ALL
SELECT 3, '7501234567897', 'Cartulina Blanca', 'Paquete 10 hojas, 180g', 12.00, 25.00, 40, 10, 80, 'PAQUETE', id FROM usuarios WHERE email = 'alericoher@papeleriasmart.com';

INSERT INTO movimientos_inventario (producto_id, usuario_id, tipo_movimiento, cantidad, precio_unitario, referencia, notas)
SELECT id, (SELECT id FROM usuarios WHERE email = 'alesilva@papeleriasmart.com' LIMIT 1), 'COMPRA', 50, 35.00, 'FACT-001', 'Compra inicial' FROM productos WHERE nombre = 'Cuaderno Profesional A5'
UNION ALL
SELECT id, (SELECT id FROM usuarios WHERE email = 'alesilva@papeleriasmart.com' LIMIT 1), 'COMPRA', 150, 5.00, 'FACT-002', 'Compra inicial' FROM productos WHERE nombre = 'Bolígrafo Retráctil Negro'
UNION ALL
SELECT id, (SELECT id FROM usuarios WHERE email = 'alesilva@papeleriasmart.com' LIMIT 1), 'COMPRA', 30, 80.00, 'FACT-003', 'Compra inicial' FROM productos WHERE nombre = 'Papel Bond Carta 75g'
UNION ALL
SELECT id, (SELECT id FROM usuarios WHERE email = 'alesilva@papeleriasmart.com' LIMIT 1), 'COMPRA', 20, 45.00, 'FACT-004', 'Compra inicial' FROM productos WHERE nombre = 'Engrapadora Metálica'
UNION ALL
SELECT id, (SELECT id FROM usuarios WHERE email = 'alesilva@papeleriasmart.com' LIMIT 1), 'COMPRA', 70, 25.00, 'FACT-005', 'Compra inicial' FROM productos WHERE nombre = 'Juego de Colores 12 piezas';

-- ============================================================
-- 6. TRIGGERS FUNCIONALES
-- ============================================================
CREATE TABLE auditoria_productos (
    id INT AUTO_INCREMENT PRIMARY KEY,
    producto_id CHAR(36),
    campo VARCHAR(50),
    valor_anterior TEXT,
    valor_nuevo TEXT,
    usuario_id CHAR(36),
    fecha TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

DELIMITER $$
CREATE TRIGGER AuditarProductos
AFTER UPDATE ON productos
FOR EACH ROW
BEGIN
    IF OLD.precio_venta != NEW.precio_venta THEN
        INSERT INTO auditoria_productos (producto_id, campo, valor_anterior, valor_nuevo)
        VALUES (NEW.id, 'precio_venta', OLD.precio_venta, NEW.precio_venta);
    END IF;
END$$
DELIMITER ;

-- 2 --
DELIMITER $$
CREATE TRIGGER ValidarStockNegativo
BEFORE UPDATE ON productos
FOR EACH ROW
BEGIN
    IF NEW.stock_actual < 0 THEN
        SIGNAL SQLSTATE '45000' 
        SET MESSAGE_TEXT = 'Error: El stock no puede ser negativo';
    END IF;
END$$
DELIMITER ;

-- 3--
DELIMITER $$
CREATE TRIGGER RegistrarMovimientoCompra
AFTER INSERT ON productos
FOR EACH ROW
BEGIN
    INSERT INTO movimientos_inventario (producto_id, usuario_id, tipo_movimiento, cantidad, precio_unitario)
    VALUES (NEW.id, NEW.creado_por, 'COMPRA', NEW.stock_actual, NEW.precio_compra);
END$$
DELIMITER ;
-- ============================================================
-- 7. VERIFICACIÓN FINAL
-- ============================================================
SHOW TRIGGERS;

SHOW TRIGGERS WHERE `Table` = 'productos';
-- Esto debe dar ERROR porque stock_actual no puede ser negativo
UPDATE productos SET stock_actual = -10 WHERE nombre = 'Bolígrafo Retráctil Negro';


-- ========================================================================================================================================
--                                                            Ejecuciones
-- ========================================================================================================================================
-- -------------------------------------------------------GESTIÓN DE PRODUCTOS (INVENTARIO)------------------------------------------------
-- VER TODOS LOS PRODUCTOS (LISTADO)
SELECT --
    p.id,
    p.nombre AS producto,
    c.nombre AS categoria,
    p.precio_venta,
    p.stock_actual,
    p.stock_minimo,
    p.esta_activo
FROM productos p
INNER JOIN categorias c ON p.categoria_id = c.id
ORDER BY p.nombre;

-- AGREGAR UN NUEVO PRODUCTO
INSERT INTO productos (categoria_id, codigo_barras, nombre, descripcion, precio_compra, precio_venta, stock_actual, stock_minimo, stock_maximo, unidad_medida, creado_por) SELECT 1, '7501234567999', 'Cuaderno de Prueba', 'Cuaderno de prueba para el video', 10.00, 18.00, 30, 5, 60, 'PIEZA', id FROM usuarios WHERE email = 'leonardo.lopez@papeleriasmart.com';

-- 	VER PRODUCTOS CON STOCK CRÍTICO
SELECT * FROM vista_stock_critico;

-- ACTUALIZAR STOCK DE UN PRODUCTO
UPDATE productos SET stock_actual = 50 WHERE nombre = 'Cuaderno de Prueba';

-- ELIMINAR PRODUCTO DE PRUEBA
DELETE FROM productos WHERE nombre = 'Cuaderno de Prueba';


--  --------------------------------------------------REGISTRO DE VENTAS (PUNTO DE VENTA)--------------------------------------------
-- VER STOCK ACTUAL DE PRODUCTOS A VENDER
SELECT nombre, stock_actual, precio_venta 
FROM productos WHERE nombre IN ('Bolígrafo Retráctil Negro', 'Cuaderno Profesional A5');

--  Crear una Vneta 
INSERT INTO ventas (id, usuario_id, cliente_nombre, cliente_telefono, subtotal, iva, total, metodo_pago) 
VALUES (UUID(), (SELECT id FROM usuarios WHERE email = 'leonardo.lopez@papeleriasmart.com'), 'Cliente Video', '555-123-4567', 0, 0, 0, 'EFECTIVO');

-- Obtener el id de la venta creada 
SELECT id FROM ventas WHERE cliente_nombre = 'Cliente Video' ORDER BY fecha_venta DESC LIMIT 1;

-- INSERTAR DETALLES DE VENTA
INSERT INTO detalles_venta (venta_id, producto_id, cantidad, precio_unitario) 
VALUES 
('c49cef68-6c12-11f1-abd4-ec24ed3b5c1d', (SELECT id FROM productos WHERE nombre = 'Bolígrafo Retráctil Negro' LIMIT 1), 2, 12.00),
('c49cef68-6c12-11f1-abd4-ec24ed3b5c1d', (SELECT id FROM productos WHERE nombre = 'Cuaderno Profesional A5' LIMIT 1), 1, 65.00);

-- ACTUALIZAR SUBTOTAL, IVA Y TOTAL DE LA VENTA (REEMPLAZA 'AQUI_EL_ID')
UPDATE ventas v JOIN (SELECT venta_id, SUM(cantidad * precio_unitario) AS total_detalle 
FROM detalles_venta WHERE venta_id = 'AQUI_EL_ID' GROUP BY venta_id) d ON v.id = d.venta_id SET v.subtotal = d.total_detalle, v.iva = d.total_detalle * 0.16, v.total = d.total_detalle * 1.16 
WHERE v.id = 'AQUI_EL_ID';

-- ACTUALIZAR STOCK DE PRODUCTOS VENDIDOS
UPDATE productos SET stock_actual = stock_actual - 1 WHERE nombre = 'Cuaderno Profesional A5';
UPDATE productos SET stock_actual = stock_actual - 2 WHERE nombre = 'Bolígrafo Retráctil Negro';

-- REGISTRAR MOVIMIENTO DE INVENTARIO 
INSERT INTO movimientos_inventario (producto_id, usuario_id, tipo_movimiento, cantidad, precio_unitario, referencia) 
SELECT id, (SELECT id FROM usuarios WHERE email = 'leonardo.lopez@papeleriasmart.com'), 'VENTA', -2, 12.00, CONCAT('VENTA-', (SELECT id FROM ventas WHERE cliente_nombre = 'Cliente Video' ORDER BY fecha_venta DESC LIMIT 1)) 
FROM productos WHERE nombre = 'Bolígrafo Retráctil Negro' UNION ALL SELECT id, (SELECT id FROM usuarios 
WHERE email = 'leonardo.lopez@papeleriasmart.com'), 'VENTA', -1, 65.00, CONCAT('VENTA-', (SELECT id FROM ventas WHERE cliente_nombre = 'Cliente Video' ORDER BY fecha_venta DESC LIMIT 1)) FROM productos WHERE nombre = 'Cuaderno Profesional A5';

-- VERIFICAR VENTA COMPLETA
SELECT * FROM ventas WHERE cliente_nombre = 'Cliente Video';
SELECT * FROM detalles_venta WHERE venta_id = 'AQUI_EL_ID';
SELECT nombre, stock_actual FROM productos WHERE nombre IN ('Bolígrafo Retráctil Negro', 'Cuaderno Profesional A5');
SELECT * FROM movimientos_inventario WHERE referencia LIKE 'VENTA-%' ORDER BY created_at DESC LIMIT 2;

--  -------------------------------------------------REPORTES Y DASHBOARD (PARA EL ANALISTA)-----------------------------------------------
-- TOP 10 PRODUCTOS MÁS VENDIDOS
SELECT * FROM vista_top_productos;

--  ROTACIÓN ABC DE PRODUCTOS
SELECT * FROM vista_rotacion_productos;

-- MOVIMIENTOS DE INVENTARIO POR MES
SELECT * FROM vista_movimientos_mensuales;

-- PRODUCTOS CON STOCK CRÍTICO
SELECT * FROM vista_stock_critico;


--  -------------------------------------------------GESTIÓN DE USUARIOS Y ROLES-----------------------------------------------------
-- VER TODOS LOS USUARIOS CON SU ROL
SELECT u.id, u.email, u.nombre_completo, r.nombre AS rol FROM usuarios u INNER JOIN roles r ON u.rol_id = r.id;

-- VER SOLO LOS ROLES DISPONIBLES
SELECT * FROM roles;

-- CAMBIAR EL ROL DE UN USUARIO (EJEMPLO: CAMBIAR A TESTER)
UPDATE usuarios SET rol_id = 4 WHERE email = 'leonardo.lopez@papeleriasmart.com';

-- VERIFICAR EL CAMBIO DE ROL
SELECT u.email, u.nombre_completo, r.nombre AS rol FROM usuarios u INNER JOIN roles r ON u.rol_id = r.id WHERE u.email = 'leonardo.lopez@papeleriasmart.com';

-- REVERTIR EL ROL A SU ORIGINAL (DESARROLLADOR)
UPDATE usuarios SET rol_id = 3 WHERE email = 'leonardo.lopez@papeleriasmart.com';

--  VERIFICAR QUE QUEDÓ BIEN
SELECT u.email, u.nombre_completo, r.nombre AS rol FROM usuarios u INNER JOIN roles r ON u.rol_id = r.id;



--  --------------------------------------------------------OPERACIONES DE NEGOCIO---------------------------------------------------------
-- GANANCIA POR PRODUCTO
SELECT nombre, precio_compra, precio_venta, (precio_venta - precio_compra) AS ganancia 
FROM productos WHERE esta_activo = 1 ORDER BY ganancia DESC;

-- VALOR TOTAL DEL INVENTARIO
SELECT SUM(stock_actual * precio_compra) AS valor_inventario FROM productos WHERE esta_activo = 1;

-- PRODUCTOS MÁS RENTABLES
SELECT nombre, (precio_venta - precio_compra) AS ganancia, stock_actual 
FROM productos WHERE esta_activo = 1 ORDER BY ganancia DESC LIMIT 5;

-- INGRESOS TOTALES POR MES 
SELECT DATE_FORMAT(fecha_venta, '%Y-%m') AS mes, COUNT(*) AS num_ventas, SUM(total) AS ingresos_totales 
FROM ventas GROUP BY mes ORDER BY mes DESC;

-- PRODUCTOS CON MAYOR ROTACIÓN
SELECT cliente_nombre, COUNT(*) AS compras, SUM(total) AS total_gastado 
FROM ventas WHERE cliente_nombre IS NOT NULL GROUP BY cliente_nombre ORDER BY total_gastado DESC LIMIT 5;



--  ------------------------------------------------------OPERACIONES DE MANTENIMIENTO----------------------------------------------------------
-- VER TODAS LAS TABLAS DE LA BASE DE DATOS
SHOW TABLES;

--  VER ESTRUCTURA DE UNA TABLA
DESCRIBE productos;

-- SHOW TRIGGERS;
SHOW TRIGGERS;

-- VER TODAS LAS VISTAS
SHOW FULL TABLES WHERE Table_type = 'VIEW';

-- VER LAS ÚLTIMAS 5 VENTAS REGISTRADAS
SELECT * FROM ventas ORDER BY fecha_venta DESC LIMIT 5;

-- VER LAS ÚLTIMAS 10 ACCIONES EN MOVIMIENTOS DE INVENTARIO
SELECT * FROM movimientos_inventario ORDER BY created_at DESC LIMIT 10;














-- --------------------------------------------------------------------------------------------------------
-- FIN DE SCRIPT --
-- --------------------------------------------------------------------------------------------------------
