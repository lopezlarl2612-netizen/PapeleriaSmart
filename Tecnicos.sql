-- MySQL dump 10.13  Distrib 8.0.45, for Win64 (x86_64)
--
-- Host: localhost    Database: servicedeskti
-- ------------------------------------------------------
-- Server version	8.0.45

/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!50503 SET NAMES utf8 */;
/*!40103 SET @OLD_TIME_ZONE=@@TIME_ZONE */;
/*!40103 SET TIME_ZONE='+00:00' */;
/*!40014 SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;
/*!40111 SET @OLD_SQL_NOTES=@@SQL_NOTES, SQL_NOTES=0 */;

--
-- Table structure for table `categorias`
--

DROP TABLE IF EXISTS `categorias`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `categorias` (
  `id_categoria` int NOT NULL AUTO_INCREMENT,
  `nombre` varchar(100) NOT NULL,
  `descripcion` text,
  `tipo_categoria` varchar(100) DEFAULT NULL,
  `estatus` tinyint DEFAULT '1',
  PRIMARY KEY (`id_categoria`),
  UNIQUE KEY `uq_categoria_nombre` (`nombre`),
  CONSTRAINT `chk_estatus_Categoria` CHECK ((`estatus` in (0,1)))
) ENGINE=InnoDB AUTO_INCREMENT=5 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `categorias`
--

LOCK TABLES `categorias` WRITE;
/*!40000 ALTER TABLE `categorias` DISABLE KEYS */;
INSERT INTO `categorias` VALUES (1,'Hardware','Problemas físicos de equipo','Incidente',1),(2,'Software','Errores en aplicaciones','Incidente',1),(3,'Red','Problemas de conectividad','Incidente',1),(4,'Mantenimiento','Solicitudes preventivas','Servicio',1);
/*!40000 ALTER TABLE `categorias` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `comentarios_ticket`
--

DROP TABLE IF EXISTS `comentarios_ticket`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `comentarios_ticket` (
  `id_comentario` int NOT NULL AUTO_INCREMENT,
  `ticket_id` int DEFAULT NULL,
  `tecnico_id` int DEFAULT NULL,
  `comentario` text NOT NULL,
  `fecha_comentario` datetime DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id_comentario`),
  KEY `fk_comentario_ticket` (`ticket_id`),
  KEY `fk_comentario_tecnico` (`tecnico_id`),
  CONSTRAINT `fk_comentario_tecnico` FOREIGN KEY (`tecnico_id`) REFERENCES `tecnicos` (`id_tecnico`) ON DELETE SET NULL ON UPDATE CASCADE,
  CONSTRAINT `fk_comentario_ticket` FOREIGN KEY (`ticket_id`) REFERENCES `tickets` (`id_ticket`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=8 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `comentarios_ticket`
--

LOCK TABLES `comentarios_ticket` WRITE;
/*!40000 ALTER TABLE `comentarios_ticket` DISABLE KEYS */;
INSERT INTO `comentarios_ticket` VALUES (1,1,1,'Se revisa fuente de poder','2026-03-29 14:48:11'),(2,1,1,'Se solicita reemplazo','2026-03-29 14:48:11'),(3,2,2,'Error identificado en base de datos','2026-03-29 14:48:11'),(4,3,3,'Se reinicia router','2026-03-29 14:48:11'),(5,4,2,'Instalación en progreso','2026-03-29 14:48:11'),(6,5,1,'Equipo entregado al usuario','2026-03-29 14:48:11'),(7,6,1,'Pendiente revisión de cartucho','2026-03-29 14:48:11');
/*!40000 ALTER TABLE `comentarios_ticket` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `departamentos`
--

DROP TABLE IF EXISTS `departamentos`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `departamentos` (
  `id_departamento` int NOT NULL AUTO_INCREMENT,
  `nombre` varchar(100) NOT NULL,
  `descripcion` text,
  `ubicacion` varchar(150) DEFAULT NULL,
  `presupuesto` decimal(12,2) DEFAULT NULL,
  `telefono` varchar(20) DEFAULT NULL,
  `extension` varchar(10) DEFAULT NULL,
  `responsable` varchar(150) DEFAULT NULL,
  `estatus` tinyint DEFAULT '1',
  PRIMARY KEY (`id_departamento`),
  UNIQUE KEY `uq_departamento_nombre` (`nombre`),
  CONSTRAINT `chk_estatus_Departamento` CHECK ((`estatus` in (0,1))),
  CONSTRAINT `chk_presupuesto` CHECK ((`presupuesto` >= 0))
) ENGINE=InnoDB AUTO_INCREMENT=6 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `departamentos`
--

LOCK TABLES `departamentos` WRITE;
/*!40000 ALTER TABLE `departamentos` DISABLE KEYS */;
INSERT INTO `departamentos` VALUES (1,'Recursos Humanos','Gestión de personal','Edificio A',50000.00,'5551234567','101','Laura Méndez',1),(2,'Finanzas','Control financiero','Edificio B',80000.00,'5559876543','102','Carlos Ruiz',1),(3,'Ventas','Área comercial','Edificio C',120000.00,'5554567890','103','Ana Torres',1),(4,'Sistemas','Soporte técnico','Edificio D',150000.00,'5553216549','104','Miguel Sánchez',1),(5,'Logística','Distribución y almacén','Edificio E',70000.00,'5556543210','105','Pedro López',0);
/*!40000 ALTER TABLE `departamentos` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `empleados`
--

DROP TABLE IF EXISTS `empleados`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `empleados` (
  `id_empleado` int NOT NULL AUTO_INCREMENT,
  `nombre` varchar(100) NOT NULL,
  `apellido_paterno` varchar(100) DEFAULT NULL,
  `apellido_materno` varchar(100) DEFAULT NULL,
  `correo` varchar(150) NOT NULL,
  `telefono` varchar(20) DEFAULT NULL,
  `extension` varchar(10) DEFAULT NULL,
  `puesto` varchar(100) DEFAULT NULL,
  `salario` decimal(10,2) DEFAULT NULL,
  `fecha_ingreso` date DEFAULT NULL,
  `fecha_salida` date DEFAULT NULL,
  `estatus` tinyint DEFAULT '1',
  `departamento_id` int DEFAULT NULL,
  PRIMARY KEY (`id_empleado`),
  UNIQUE KEY `uq_empleado_correo` (`correo`),
  KEY `fk_empleado_departamento` (`departamento_id`),
  CONSTRAINT `fk_empleado_departamento` FOREIGN KEY (`departamento_id`) REFERENCES `departamentos` (`id_departamento`) ON DELETE SET NULL ON UPDATE CASCADE,
  CONSTRAINT `chk_fechas` CHECK ((`fecha_salida` >= `fecha_ingreso`)),
  CONSTRAINT `chk_salario` CHECK ((`salario` >= 0))
) ENGINE=InnoDB AUTO_INCREMENT=6 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `empleados`
--

LOCK TABLES `empleados` WRITE;
/*!40000 ALTER TABLE `empleados` DISABLE KEYS */;
INSERT INTO `empleados` VALUES (1,'Juan','Pérez','Gómez','juan.perez@empresa.com','5551111111','201','Analista',12000.00,'2022-01-10',NULL,1,1),(2,'María','López','Hernández','maria.lopez@empresa.com','5552222222','202','Contadora',15000.00,'2021-03-15',NULL,1,2),(3,'Luis','Ramírez','Santos','luis.ramirez@empresa.com','5553333333','203','Vendedor',10000.00,'2023-06-01',NULL,1,3),(4,'Ana','García','Flores','ana.garcia@empresa.com','5554444444','204','Soporte',13000.00,'2020-09-20',NULL,1,4),(5,'Pedro','Martínez','Díaz','pedro.martinez@empresa.com','5555555555','205','Almacenista',9000.00,'2019-11-05','2024-01-01',0,5);
/*!40000 ALTER TABLE `empleados` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `tecnicos`
--

DROP TABLE IF EXISTS `tecnicos`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `tecnicos` (
  `id_tecnico` int NOT NULL AUTO_INCREMENT,
  `nombre` varchar(100) NOT NULL,
  `apellido_paterno` varchar(100) DEFAULT NULL,
  `apellido_materno` varchar(100) DEFAULT NULL,
  `correo` varchar(150) NOT NULL,
  `telefono` varchar(20) DEFAULT NULL,
  `especialidad` varchar(100) DEFAULT NULL,
  `nivel_soporte` varchar(50) DEFAULT NULL,
  `certificaciones` text,
  `fecha_contratacion` date NOT NULL,
  `Fecha_finalizacion` date DEFAULT NULL,
  `estatus` tinyint DEFAULT '1',
  PRIMARY KEY (`id_tecnico`),
  UNIQUE KEY `uq_tecnico_correo` (`correo`),
  CONSTRAINT `chk_estatus_tecnico` CHECK ((`estatus` in (0,1))),
  CONSTRAINT `chk_fecha` CHECK ((`fecha_finalizacion` >= `fecha_contratacion`)),
  CONSTRAINT `chk_nivel_soporte` CHECK ((`nivel_soporte` in (_utf8mb4'L1',_utf8mb4'L2',_utf8mb4'L3')))
) ENGINE=InnoDB AUTO_INCREMENT=5 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `tecnicos`
--

LOCK TABLES `tecnicos` WRITE;
/*!40000 ALTER TABLE `tecnicos` DISABLE KEYS */;
INSERT INTO `tecnicos` VALUES (1,'Carlos','Sánchez','Lopez','carlos.soporte@empresa.com','5556666666','Hardware','L1','A+','2021-02-01',NULL,1),(2,'Lucía','Fernández','Ruiz','lucia.soporte@empresa.com','5557777777','Software','L2','ITIL','2020-07-10',NULL,1),(3,'Miguel','Torres','Castro','miguel.soporte@empresa.com','5558888888','Redes','L3','CCNA','2019-05-20',NULL,1),(4,'Leonardo Arturo','Lopez','Ramos','leonlpz82373@gmail.com','5573943757','Base de Datos','L2','Sin certificaciones previas','2026-03-29',NULL,1);
/*!40000 ALTER TABLE `tecnicos` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `tickets`
--

DROP TABLE IF EXISTS `tickets`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `tickets` (
  `id_ticket` int NOT NULL AUTO_INCREMENT,
  `titulo` varchar(200) NOT NULL,
  `descripcion` text,
  `fecha_creacion` datetime DEFAULT CURRENT_TIMESTAMP,
  `fecha_cierre` datetime DEFAULT NULL,
  `prioridad` varchar(50) DEFAULT NULL,
  `estado` varchar(50) DEFAULT 'Abierto',
  `tipo_ticket` varchar(100) DEFAULT NULL,
  `impacto` varchar(50) DEFAULT NULL,
  `urgencia` varchar(50) DEFAULT NULL,
  `tiempo_estimado` int DEFAULT NULL,
  `tiempo_real` int DEFAULT NULL,
  `empleado_id` int DEFAULT NULL,
  `tecnico_id` int DEFAULT NULL,
  `categoria_id` int DEFAULT NULL,
  PRIMARY KEY (`id_ticket`),
  KEY `fk_ticket_empleado` (`empleado_id`),
  KEY `fk_ticket_tecnico` (`tecnico_id`),
  KEY `fk_ticket_categoria` (`categoria_id`),
  CONSTRAINT `fk_ticket_categoria` FOREIGN KEY (`categoria_id`) REFERENCES `categorias` (`id_categoria`) ON DELETE SET NULL ON UPDATE CASCADE,
  CONSTRAINT `fk_ticket_empleado` FOREIGN KEY (`empleado_id`) REFERENCES `empleados` (`id_empleado`) ON DELETE SET NULL ON UPDATE CASCADE,
  CONSTRAINT `fk_ticket_tecnico` FOREIGN KEY (`tecnico_id`) REFERENCES `tecnicos` (`id_tecnico`) ON DELETE SET NULL ON UPDATE CASCADE,
  CONSTRAINT `chk_estado` CHECK ((`estado` in (_utf8mb4'Abierto',_utf8mb4'En proceso',_utf8mb4'Cerrado',_utf8mb4'Cancelado'))),
  CONSTRAINT `chk_prioridad` CHECK ((`prioridad` in (_utf8mb4'Baja',_utf8mb4'Media',_utf8mb4'Alta',_utf8mb4'Critica'))),
  CONSTRAINT `chk_tiempos` CHECK (((`tiempo_estimado` >= 0) and (`tiempo_real` >= 0)))
) ENGINE=InnoDB AUTO_INCREMENT=10 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `tickets`
--

LOCK TABLES `tickets` WRITE;
/*!40000 ALTER TABLE `tickets` DISABLE KEYS */;
INSERT INTO `tickets` VALUES (1,'No enciende PC','Equipo no responde','2026-03-29 14:48:06',NULL,'Alta','Abierto','Incidente','Alto','Alta',120,NULL,1,1,1),(2,'Error en sistema contable','No guarda datos','2026-03-29 14:48:06',NULL,'Critica','En proceso','Incidente','Alto','Alta',180,60,2,2,2),(3,'Sin internet','No hay conexión en oficina','2026-03-29 14:48:06',NULL,'Alta','Cerrado','Incidente','Alto','Media',60,50,3,3,3),(4,'Instalar software','Requiere Office','2026-03-29 14:48:06',NULL,'Media','Abierto','Solicitud','Medio','Baja',30,NULL,1,2,2),(5,'Mantenimiento PC','Limpieza general','2026-03-29 14:48:06',NULL,'Baja','Cerrado','Mantenimiento','Bajo','Baja',45,40,4,1,4),(6,'Falla impresora','No imprime','2026-03-29 14:48:06',NULL,'Media','En proceso','Incidente','Medio','Media',60,30,2,1,1),(7,'Configuración de Entorno DBA Leonardo','Configuración de acceso a ServiceDeskTI y validación de triggers de auditoría.','2026-03-29 14:55:25',NULL,'Alta','En proceso','Infraestructura','Medio','Alta',60,NULL,1,4,3),(8,'Optimización de Consultas SQL','Revisión de índices en tablas de gran volumen para la próxima clase.','2026-03-29 14:55:32',NULL,'Media','Abierto','Servicio','Bajo','Media',120,NULL,2,4,2),(9,'Respaldo de Base de Datos','Generación de dump completo de ServiceDeskTI para pruebas de recuperación.','2026-03-29 14:55:32',NULL,'Critica','Abierto','Mantenimiento','Alto','Alta',90,NULL,4,4,3);
/*!40000 ALTER TABLE `tickets` ENABLE KEYS */;
UNLOCK TABLES;
/*!40103 SET TIME_ZONE=@OLD_TIME_ZONE */;

/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
/*!40111 SET SQL_NOTES=@OLD_SQL_NOTES */;

-- Dump completed on 2026-03-29 15:06:30
