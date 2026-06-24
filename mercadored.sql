-- MySQL dump 10.13  Distrib 8.0.46, for Win64 (x86_64)
--
-- Host: 127.0.0.1    Database: mercadored
-- ------------------------------------------------------
-- Server version	8.0.46

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
-- Table structure for table `persona`
--

DROP TABLE IF EXISTS `persona`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `persona` (
  `id_persona` int NOT NULL AUTO_INCREMENT,
  `nombre` varchar(150) COLLATE utf8mb4_unicode_ci NOT NULL,
  `documento` varchar(20) COLLATE utf8mb4_unicode_ci NOT NULL,
  `correo` varchar(150) COLLATE utf8mb4_unicode_ci NOT NULL,
  `celular` varchar(20) COLLATE utf8mb4_unicode_ci NOT NULL,
  `direccion` varchar(250) COLLATE utf8mb4_unicode_ci NOT NULL,
  `contrasena` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `estado` enum('activo','inactivo','sancionado') COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'inactivo',
  `tipo` enum('comprador','vendedor','admin') COLLATE utf8mb4_unicode_ci NOT NULL,
  `fecha_registro` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id_persona`),
  UNIQUE KEY `documento` (`documento`),
  UNIQUE KEY `correo` (`correo`)
) ENGINE=InnoDB AUTO_INCREMENT=7 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `persona`
--

LOCK TABLES `persona` WRITE;
/*!40000 ALTER TABLE `persona` DISABLE KEYS */;
INSERT INTO `persona` VALUES (1,'Juan Figueroa','1234567890','juan@mercadored.com','3001234567','Bogotá, Colombia','admin123','activo','vendedor','2026-04-24 10:30:57'),(2,'Ana Forigua','1000494772','anaforigua02@gmail.com','3229485111','calle 68b #78-53','1000494772','activo','comprador','2026-04-24 10:56:30'),(6,'Alejandro Osorio','1234567893','est.anafv@smart.edu.co','3229485111','est.anafv@smart.edu.co','osorio2','inactivo','comprador','2026-06-24 09:32:19');
/*!40000 ALTER TABLE `persona` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `producto`
--

DROP TABLE IF EXISTS `producto`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `producto` (
  `id_producto` int NOT NULL AUTO_INCREMENT,
  `id_vendedor` int NOT NULL,
  `titulo` varchar(200) COLLATE utf8mb4_unicode_ci NOT NULL,
  `descripcion` text COLLATE utf8mb4_unicode_ci NOT NULL,
  `precio` decimal(15,2) NOT NULL,
  `stock` int NOT NULL DEFAULT '0',
  `categoria` varchar(100) COLLATE utf8mb4_unicode_ci NOT NULL,
  `imagen_url` longblob,
  `estado_producto` enum('nuevo','usado') COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'nuevo',
  `visibilidad` enum('activo','oculto','eliminado') COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'activo',
  `fecha_creacion` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id_producto`),
  KEY `id_vendedor` (`id_vendedor`),
  CONSTRAINT `producto_ibfk_1` FOREIGN KEY (`id_vendedor`) REFERENCES `vendedor` (`id_vendedor`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=27 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `producto`
--

LOCK TABLES `producto` WRITE;
/*!40000 ALTER TABLE `producto` DISABLE KEYS */;
INSERT INTO `producto` VALUES (1,1,'Laptop HP 15','Laptop HP 15 pulgadas, Core i5, 8GB RAM, 256GB SSD',2500000.00,5,'Tecnología',NULL,'nuevo','activo','2026-04-24 10:30:57'),(2,1,'Teclado mecánico RGB','Teclado mecánico con switches azules y retroiluminación RGB',350000.00,12,'Tecnología',NULL,'nuevo','activo','2026-04-24 10:30:57'),(3,1,'Silla gamer ergonómica','Silla para gaming con soporte lumbar ajustable',850000.00,3,'Muebles',NULL,'nuevo','eliminado','2026-04-24 10:30:57'),(7,1,'Monitor Samsung 24','Monitor LED 24 pulgadas Full HD, 75Hz',650000.00,10,'Tecnología',NULL,'nuevo','activo','2026-04-24 12:35:43'),(8,1,'Mouse inalámbrico Logitech','Mouse ergonómico con sensor de alta precisión',120000.00,25,'Tecnología',NULL,'nuevo','activo','2026-04-24 12:35:43'),(9,1,'Escritorio de oficina','Escritorio en madera con estructura metálica',450000.00,8,'Muebles',NULL,'nuevo','activo','2026-04-24 12:35:43'),(10,1,'Audífonos Bluetooth Sony','Audífonos con cancelación de ruido activa',550000.00,15,'Tecnología',NULL,'nuevo','activo','2026-04-24 12:35:43'),(11,1,'Impresora HP Laser','Impresora láser multifuncional monocromática',780000.00,5,'Tecnología',NULL,'nuevo','activo','2026-04-24 12:35:43'),(12,1,'Estantería metálica','Estantería de 5 niveles para almacenamiento',320000.00,12,'Muebles',NULL,'nuevo','activo','2026-04-24 12:35:43'),(13,1,'Disco duro externo 1TB','Unidad de almacenamiento portátil USB 3.0',280000.00,20,'Tecnología',NULL,'nuevo','activo','2026-04-24 12:35:43'),(14,1,'Cámara Web HD','Cámara web 1080p con micrófono integrado',190000.00,30,'Tecnología',NULL,'nuevo','activo','2026-04-24 12:35:43'),(15,1,'Lámpara de escritorio LED','Lámpara con brazo flexible y ajuste de tono',85000.00,18,'Muebles',NULL,'nuevo','activo','2026-04-24 12:35:43'),(16,1,'Router Wi-Fi 6','Router inalámbrico de alta velocidad',310000.00,7,'Tecnología',NULL,'nuevo','activo','2026-04-24 12:35:43'),(17,1,'Silla de oficina ejecutiva','Silla ergonómica con malla transpirable',520000.00,6,'Muebles',NULL,'nuevo','activo','2026-04-24 12:35:43'),(18,1,'Memoria USB 64GB','Pendrive de alta velocidad metálico',45000.00,50,'Tecnología',NULL,'nuevo','activo','2026-04-24 12:35:43'),(19,1,'Teclado numérico externo','Teclado USB adicional para portátiles',65000.00,14,'Tecnología',NULL,'nuevo','activo','2026-04-24 12:35:43'),(20,1,'Mesa de centro moderna','Mesa de centro con diseño minimalista',290000.00,4,'Muebles',NULL,'nuevo','activo','2026-04-24 12:35:43'),(21,1,'Cargador universal USB-C','Cargador de pared de carga rápida 65W',95000.00,22,'Tecnología',NULL,'nuevo','activo','2026-04-24 12:35:43'),(22,1,'Organizador de cables','Set de 20 piezas para gestión de cableado',25000.00,40,'Tecnología',NULL,'nuevo','activo','2026-04-24 12:35:43'),(23,1,'Soporte para laptop','Base de aluminio ajustable para notebook',110000.00,15,'Tecnología',NULL,'nuevo','activo','2026-04-24 12:35:43'),(24,1,'Armario pequeño','Armario organizador de dos puertas',680000.00,3,'Muebles',NULL,'nuevo','activo','2026-04-24 12:35:43'),(25,1,'Mousepad grande XL','Mousepad de escritorio antideslizante',75000.00,25,'Tecnología',NULL,'nuevo','activo','2026-04-24 12:35:43'),(26,1,'Base refrigerante para laptop','Base con 4 ventiladores silenciosos',130000.00,9,'Tecnología',NULL,'nuevo','activo','2026-04-24 12:35:43');
/*!40000 ALTER TABLE `producto` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `vendedor`
--

DROP TABLE IF EXISTS `vendedor`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `vendedor` (
  `id_vendedor` int NOT NULL AUTO_INCREMENT,
  `id_persona` int NOT NULL,
  `cuenta_bancaria` varchar(30) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `banco` varchar(100) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `identidad_validada` tinyint(1) NOT NULL DEFAULT '0',
  `reputacion` decimal(3,2) NOT NULL DEFAULT '0.00',
  PRIMARY KEY (`id_vendedor`),
  UNIQUE KEY `id_persona` (`id_persona`),
  CONSTRAINT `vendedor_ibfk_1` FOREIGN KEY (`id_persona`) REFERENCES `persona` (`id_persona`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `vendedor`
--

LOCK TABLES `vendedor` WRITE;
/*!40000 ALTER TABLE `vendedor` DISABLE KEYS */;
INSERT INTO `vendedor` VALUES (1,1,'0012345678901','Bancolombia',1,4.50);
/*!40000 ALTER TABLE `vendedor` ENABLE KEYS */;
UNLOCK TABLES;
/*!40103 SET TIME_ZONE=@OLD_TIME_ZONE */;

/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
/*!40111 SET SQL_NOTES=@OLD_SQL_NOTES */;

-- Dump completed on 2026-06-24  9:56:50
