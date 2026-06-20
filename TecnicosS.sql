CREATE DATABASE ServiceDeskTI;

USE ServiceDeskTI;

CREATE TABLE Departamentos (
    id_departamento INT AUTO_INCREMENT,
    nombre VARCHAR(100) NOT NULL,
    descripcion TEXT,
    ubicacion VARCHAR(150),
    presupuesto DECIMAL(12,2),
    telefono VARCHAR(20),
    extension VARCHAR(10),
    responsable VARCHAR(150),
    estatus TINYINT DEFAULT 1, -- 1 'Activo', 0 - 'Inactivo'
    CONSTRAINT pk_departamentos PRIMARY KEY (id_departamento),
    CONSTRAINT uq_departamento_nombre UNIQUE (nombre),
    CONSTRAINT chk_estatus_Departamento CHECK (estatus IN (0,1)),
    CONSTRAINT chk_presupuesto CHECK (presupuesto >= 0)
);

CREATE TABLE Empleados (
    id_empleado INT AUTO_INCREMENT,
    nombre VARCHAR(100) NOT NULL,
    apellido_paterno VARCHAR(100),
    apellido_materno VARCHAR(100),
    correo VARCHAR(150) NOT NULL,
    telefono VARCHAR(20),
    extension VARCHAR(10),
    puesto VARCHAR(100),
    salario DECIMAL(10,2),
    fecha_ingreso DATE,
    fecha_salida DATE,
    estatus TINYINT DEFAULT 1, -- 1 'Activo', 0 - 'Inactivo'
    departamento_id INT,
    CONSTRAINT pk_empleados PRIMARY KEY (id_empleado),
    CONSTRAINT uq_empleado_correo UNIQUE (correo),
    CONSTRAINT chk_fechas CHECK (fecha_salida >= fecha_ingreso),
    CONSTRAINT fk_empleado_departamento 
        FOREIGN KEY (departamento_id)
        REFERENCES Departamentos(id_departamento)
        ON DELETE SET NULL
        ON UPDATE CASCADE,
    CONSTRAINT chk_salario CHECK (salario >= 0)
);

CREATE TABLE Tecnicos (
    id_tecnico INT AUTO_INCREMENT,
    nombre VARCHAR(100) NOT NULL,
    apellido_paterno VARCHAR(100),
    apellido_materno VARCHAR(100),
    correo VARCHAR(150) NOT NULL,
    telefono VARCHAR(20),
    especialidad VARCHAR(100),
    nivel_soporte VARCHAR(50),
    certificaciones TEXT,
    fecha_contratacion DATE NOT NULL,
    Fecha_finalizacion DATE,
    estatus TINYINT DEFAULT 1, -- 1 'Activo', 0 - 'Inactivo'
    CONSTRAINT pk_tecnicos PRIMARY KEY (id_tecnico),
    CONSTRAINT uq_tecnico_correo UNIQUE (correo),
    CONSTRAINT chk_estatus_tecnico CHECK (estatus IN (0,1)),
    CONSTRAINT chk_fecha CHECK (fecha_finalizacion >= fecha_contratacion),
    CONSTRAINT chk_nivel_soporte CHECK (nivel_soporte IN ('L1','L2','L3'))
);

CREATE TABLE Categorias (
    id_categoria INT AUTO_INCREMENT,
    nombre VARCHAR(100) NOT NULL,
    descripcion TEXT,
    tipo_categoria VARCHAR(100),
    estatus TINYINT DEFAULT 1, -- 1 'Activo', 0 - 'Inactivo'
    CONSTRAINT pk_categorias PRIMARY KEY (id_categoria),
    CONSTRAINT chk_estatus_Categoria CHECK (estatus IN (0,1)),
    CONSTRAINT uq_categoria_nombre UNIQUE (nombre)
);

CREATE TABLE Tickets (
    id_ticket INT AUTO_INCREMENT,
    titulo VARCHAR(200) NOT NULL,
    descripcion TEXT,
    fecha_creacion DATETIME DEFAULT CURRENT_TIMESTAMP,
    fecha_cierre DATETIME,
    prioridad VARCHAR(50),
    estado VARCHAR(50) DEFAULT 'Abierto',
    tipo_ticket VARCHAR(100),
    impacto VARCHAR(50),
    urgencia VARCHAR(50),
    tiempo_estimado INT,
    tiempo_real INT,
    empleado_id INT,
    tecnico_id INT,
    categoria_id INT,
    CONSTRAINT pk_tickets PRIMARY KEY (id_ticket),
    CONSTRAINT fk_ticket_empleado 
        FOREIGN KEY (empleado_id)
        REFERENCES Empleados(id_empleado)
        ON DELETE SET NULL
        ON UPDATE CASCADE,
    CONSTRAINT fk_ticket_tecnico 
        FOREIGN KEY (tecnico_id)
        REFERENCES Tecnicos(id_tecnico)
        ON DELETE SET NULL
        ON UPDATE CASCADE,
    CONSTRAINT fk_ticket_categoria 
        FOREIGN KEY (categoria_id)
        REFERENCES Categorias(id_categoria)
        ON DELETE SET NULL
        ON UPDATE CASCADE,
    CONSTRAINT chk_prioridad 
        CHECK (prioridad IN ('Baja','Media','Alta','Critica')),
    CONSTRAINT chk_estado 
        CHECK (estado IN ('Abierto','En proceso','Cerrado','Cancelado')),
    CONSTRAINT chk_tiempos 
        CHECK (tiempo_estimado >= 0 AND tiempo_real >= 0)
);

CREATE TABLE Comentarios_Ticket (
    id_comentario INT AUTO_INCREMENT,
    ticket_id INT,
    tecnico_id INT,
    comentario TEXT NOT NULL,
    fecha_comentario DATETIME DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT pk_comentarios PRIMARY KEY (id_comentario),
    CONSTRAINT fk_comentario_ticket 
        FOREIGN KEY (ticket_id)
        REFERENCES Tickets(id_ticket)
        ON DELETE CASCADE
        ON UPDATE CASCADE,
    CONSTRAINT fk_comentario_tecnico 
        FOREIGN KEY (tecnico_id)
        REFERENCES Tecnicos(id_tecnico)
        ON DELETE SET NULL
        ON UPDATE CASCADE
);

INSERT INTO Departamentos (nombre, descripcion, ubicacion, presupuesto, telefono, extension, responsable, estatus) VALUES
('Recursos Humanos', 'Gestión de personal', 'Edificio A', 50000, '5551234567', '101', 'Laura Méndez', 1),
('Finanzas', 'Control financiero', 'Edificio B', 80000, '5559876543', '102', 'Carlos Ruiz', 1),
('Ventas', 'Área comercial', 'Edificio C', 120000, '5554567890', '103', 'Ana Torres', 1),
('Sistemas', 'Soporte técnico', 'Edificio D', 150000, '5553216549', '104', 'Miguel Sánchez', 1),
('Logística', 'Distribución y almacén', 'Edificio E', 70000, '5556543210', '105', 'Pedro López', 0);

INSERT INTO Empleados (nombre, apellido_paterno, apellido_materno, correo, telefono, extension, puesto, salario, fecha_ingreso, fecha_salida, estatus, departamento_id) VALUES
('Juan', 'Pérez', 'Gómez', 'juan.perez@empresa.com', '5551111111', '201', 'Analista', 12000, '2022-01-10', NULL, 1, 1),
('María', 'López', 'Hernández', 'maria.lopez@empresa.com', '5552222222', '202', 'Contadora', 15000, '2021-03-15', NULL, 1, 2),
('Luis', 'Ramírez', 'Santos', 'luis.ramirez@empresa.com', '5553333333', '203', 'Vendedor', 10000, '2023-06-01', NULL, 1, 3),
('Ana', 'García', 'Flores', 'ana.garcia@empresa.com', '5554444444', '204', 'Soporte', 13000, '2020-09-20', NULL, 1, 4),
('Pedro', 'Martínez', 'Díaz', 'pedro.martinez@empresa.com', '5555555555', '205', 'Almacenista', 9000, '2019-11-05', '2024-01-01', 0, 5);

INSERT INTO Tecnicos (nombre, apellido_paterno, apellido_materno, correo, telefono, especialidad, nivel_soporte, certificaciones, fecha_contratacion, fecha_finalizacion, estatus) VALUES
('Carlos', 'Sánchez', 'Lopez', 'carlos.soporte@empresa.com', '5556666666', 'Hardware', 'L1', 'A+', '2021-02-01', NULL, 1),
('Lucía', 'Fernández', 'Ruiz', 'lucia.soporte@empresa.com', '5557777777', 'Software', 'L2', 'ITIL', '2020-07-10', NULL, 1),
('Miguel', 'Torres', 'Castro', 'miguel.soporte@empresa.com', '5558888888', 'Redes', 'L3', 'CCNA', '2019-05-20', NULL, 1);

INSERT INTO Categorias (nombre, descripcion, tipo_categoria, estatus) VALUES
('Hardware', 'Problemas físicos de equipo', 'Incidente', 1),
('Software', 'Errores en aplicaciones', 'Incidente', 1),
('Red', 'Problemas de conectividad', 'Incidente', 1),
('Mantenimiento', 'Solicitudes preventivas', 'Servicio', 1);

INSERT INTO Tickets (titulo, descripcion, prioridad, estado, tipo_ticket, impacto, urgencia, tiempo_estimado, tiempo_real, empleado_id, tecnico_id, categoria_id) VALUES
('No enciende PC', 'Equipo no responde', 'Alta', 'Abierto', 'Incidente', 'Alto', 'Alta', 120, NULL, 1, 1, 1),
('Error en sistema contable', 'No guarda datos', 'Critica', 'En proceso', 'Incidente', 'Alto', 'Alta', 180, 60, 2, 2, 2),
('Sin internet', 'No hay conexión en oficina', 'Alta', 'Cerrado', 'Incidente', 'Alto', 'Media', 60, 50, 3, 3, 3),
('Instalar software', 'Requiere Office', 'Media', 'Abierto', 'Solicitud', 'Medio', 'Baja', 30, NULL, 1, 2, 2),
('Mantenimiento PC', 'Limpieza general', 'Baja', 'Cerrado', 'Mantenimiento', 'Bajo', 'Baja', 45, 40, 4, 1, 4),
('Falla impresora', 'No imprime', 'Media', 'En proceso', 'Incidente', 'Medio', 'Media', 60, 30, 2, 1, 1);

INSERT INTO Tecnicos (
    nombre, apellido_paterno, apellido_materno, correo, 
    telefono, especialidad, nivel_soporte, certificaciones, 
    fecha_contratacion, estatus
) VALUES (
    'Leonardo Arturo', 'Lopez', 'Ramos', 'leonlpz82373@gmail.com', 
    '5573943757', 'Base de Datos', 'L2', 
    'Sin certificaciones previas', '2026-03-29', 1
);

INSERT INTO Tickets (
    titulo, descripcion, prioridad, estado, tipo_ticket, 
    impacto, urgencia, tiempo_estimado, empleado_id, tecnico_id, categoria_id
) VALUES (
    'Configuración de Entorno DBA Leonardo', 
    'Configuración de acceso a ServiceDeskTI y validación de triggers de auditoría.', 
    'Alta', 'En proceso', 'Infraestructura', 'Medio', 'Alta', 60, 
    1, -- Solicitante: Juan Pérez
    4, -- Técnico: Leonardo Lopez
    3  -- Categoría: Red/Sistemas
);

INSERT INTO Tickets (titulo, descripcion, prioridad, estado, tipo_ticket, impacto, urgencia, tiempo_estimado, empleado_id, tecnico_id, categoria_id)
VALUES 
('Optimización de Consultas SQL', 'Revisión de índices en tablas de gran volumen para la próxima clase.', 'Media', 'Abierto', 'Servicio', 'Bajo', 'Media', 120, 2, 4, 2),
('Respaldo de Base de Datos', 'Generación de dump completo de ServiceDeskTI para pruebas de recuperación.', 'Critica', 'Abierto', 'Mantenimiento', 'Alto', 'Alta', 90, 4, 4, 3);


SELECT 
    T.id_ticket AS 'ID',
    T.titulo AS 'Actividad',
    C.nombre AS 'Categoría',
    T.prioridad AS 'Prioridad',
    T.estado AS 'Estado',
    T.fecha_creacion AS 'Fecha Reporte'
FROM Tickets T
INNER JOIN Categorias C ON T.categoria_id = C.id_categoria
WHERE T.tecnico_id = 4;



-- A. Servicios realizados por Categoría
SELECT 
    c.nombre AS Categoria, 
    COUNT(t.id_ticket) AS Total_Servicios
FROM Tickets t
INNER JOIN Categorias c ON t.categoria_id = c.id_categoria
WHERE t.tecnico_id = 4
GROUP BY c.nombre;

-- B. Servicios realizados por Departamento
-- (Relacionamos el ticket con el empleado y luego con su depto)
SELECT 
    d.nombre AS Departamento, 
    COUNT(t.id_ticket) AS Total_Atendido
FROM Tickets t
INNER JOIN Empleados e ON t.empleado_id = e.id_empleado
INNER JOIN Departamentos d ON e.departamento_id = d.id_departamento
WHERE t.tecnico_id = 4
GROUP BY d.nombre;

-- C. Total de servicios realizados (Histórico)
SELECT COUNT(*) AS Total_Historico_Leonardo
FROM Tickets
WHERE tecnico_id = 4;

-- D. Servicios realizados en Marzo (Basado en el año actual 2026)
SELECT COUNT(*) AS Servicios_Marzo
FROM Tickets
WHERE tecnico_id = 4 
  AND fecha_creacion >= '2026-03-01' 
  AND fecha_creacion <= '2026-03-31 23:59:59';

-- E. Servicios realizados en Abril (Proyectados o agendados)
SELECT COUNT(*) AS Servicios_Abril
FROM Tickets
WHERE tecnico_id = 4 
  AND MONTH(fecha_creacion) = 4 
  AND YEAR(fecha_creacion) = 2026;
