-- phpMyAdmin SQL Dump
-- version 4.6.6deb5
-- https://www.phpmyadmin.net/
--
-- Servidor: localhost:3306
-- Tiempo de generación: 04-08-2019 a las 17:43:27
-- Versión del servidor: 5.7.27-0ubuntu0.18.04.1
-- Versión de PHP: 7.2.19-0ubuntu0.18.04.1

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

--
-- Base de datos: `db_adminvet`
--

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `lista_medicamentos`
--

CREATE TABLE `lista_medicamentos` (
  `botiquin` int(11) NOT NULL,
  `medicamento` varchar(100) COLLATE utf8mb4_unicode_ci NOT NULL,
  `cantidad` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Disparadores `lista_medicamentos`
--
DELIMITER $$
CREATE TRIGGER `tgg_lista_medicamentos_AI_pedido` AFTER INSERT ON `lista_medicamentos` FOR EACH ROW BEGIN
	DECLARE aux INTEGER;
	DECLARE cantidadActual INTEGER;
    
    SELECT COUNT(1) INTO aux FROM lista_pedido
    WHERE medicamento = NEW.medicamento;
    
    SELECT cantidad INTO cantidadActual FROM lista_pedido
   	WHERE medicamento = NEW.medicamento;
    
    IF aux = 0  THEN
    	INSERT INTO lista_pedido(medicamento, cantidad) VALUES (NEW.medicamento, NEW.cantidad);
    ELSEIF aux = 1 THEN  
    	UPDATE lista_pedido SET cantidad = cantidadActual + NEW.cantidad WHERE medicamento = NEW.medicamento;
    END IF;
END
$$
DELIMITER ;
DELIMITER $$
CREATE TRIGGER `tgg_lista_medicamentos_AU_pedido` AFTER UPDATE ON `lista_medicamentos` FOR EACH ROW BEGIN
	DECLARE aux INTEGER;
	DECLARE cantidadActual INTEGER;
    	
    SELECT cantidad INTO cantidadActual FROM lista_pedido
   	WHERE medicamento = NEW.medicamento;
    
    SELECT COUNT(1) INTO aux FROM lista_pedido
    WHERE medicamento = NEW.medicamento;
    
    IF aux = 0  THEN
    	INSERT INTO lista_pedido(medicamento, cantidad) VALUES (NEW.medicamento, NEW.cantidad);
    ELSEIF aux = 1 THEN  
    	UPDATE lista_pedido SET cantidad = cantidadActual + NEW.cantidad WHERE medicamento = NEW.medicamento;
    END IF;
END
$$
DELIMITER ;
DELIMITER $$
CREATE TRIGGER `tgg_lista_medicamentos_BI_disponibilidad` BEFORE INSERT ON `lista_medicamentos` FOR EACH ROW BEGIN
    DECLARE dispo INTEGER;
    
    SELECT cantidadDisponible INTO dispo
    FROM tb_inventario WHERE codigo = NEW.medicamento;
   
    IF dispo < NEW.cantidad THEN
        SIGNAL SQLSTATE '0X001' SET MESSAGE_TEXT="No hay articulos suficientes.";
    ELSEIF dispo >= NEW.cantidad THEN
        UPDATE tb_inventario SET cantidadDisponible = dispo - NEW.cantidad WHERE codigo = NEW.medicamento; 
    END IF;
END
$$
DELIMITER ;
DELIMITER $$
CREATE TRIGGER `tgg_lista_medicamentos_BU_disponibilidad` BEFORE UPDATE ON `lista_medicamentos` FOR EACH ROW BEGIN
	DECLARE dispo INTEGER;
    DECLARE nuevaCantidad INTEGER;
   
   	SET nuevaCantidad = NEW.cantidad - OLD.cantidad;
    
    SELECT cantidadDisponible INTO dispo FROM tb_inventario
    WHERE codigo = NEW.medicamento;
    
    IF dispo < nuevaCantidad THEN
    	SIGNAL SQLSTATE '0X001' SET MESSAGE_TEXT="No existe esa cantidad en invetario";
    ELSEIF dispo >= nuevaCantidad THEN
    	UPDATE tb_inventario SET cantidadDisponible = dispo - nuevaCantidad WHERE codigo = NEW.medicamento;
    END IF;
    
END
$$
DELIMITER ;

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `lista_pedido`
--

CREATE TABLE `lista_pedido` (
  `pedido` int(11) DEFAULT NULL,
  `medicamento` varchar(100) COLLATE utf8mb4_unicode_ci NOT NULL,
  `cantidad` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Volcado de datos para la tabla `lista_pedido`
--

INSERT INTO `lista_pedido` (`pedido`, `medicamento`, `cantidad`) VALUES
(NULL, '0290234', 13),
(NULL, '0923452', 21);

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `receta`
--

CREATE TABLE `receta` (
  `IDTratamiento` int(11) NOT NULL,
  `IDConsulta` int(11) NOT NULL,
  `medicamento` varchar(100) COLLATE utf8mb4_unicode_ci NOT NULL,
  `cantidad` int(11) NOT NULL DEFAULT '0'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `tb_botiquin`
--

CREATE TABLE `tb_botiquin` (
  `numero` int(11) NOT NULL,
  `descripcion` varchar(100) COLLATE utf8mb4_unicode_ci NOT NULL,
  `veterinario` varchar(50) COLLATE utf8mb4_unicode_ci DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Volcado de datos para la tabla `tb_botiquin`
--

INSERT INTO `tb_botiquin` (`numero`, `descripcion`, `veterinario`) VALUES
(1, 'BOTIQUIN COLOR NEGRO MANIJA NARANJA', NULL),
(2, 'COLOR ROJO', NULL);

--
-- Disparadores `tb_botiquin`
--
DELIMITER $$
CREATE TRIGGER `tgg_botiquin_BI_customiza_ai` BEFORE INSERT ON `tb_botiquin` FOR EACH ROW BEGIN
	DECLARE num INTEGER;
    DECLARE maxi INTEGER;
    
    SELECT COUNT(1) INTO num FROM tb_botiquin;
    SELECT MAX(numero) INTO maxi FROM tb_botiquin;
    
    IF num = 0 THEN
    	SET NEW.numero = 1;
    ELSEIF num > 0 THEN
    	SET NEW.numero = maxi + 1;
    END IF;
END
$$
DELIMITER ;

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `tb_clientes`
--

CREATE TABLE `tb_clientes` (
  `IDCliente` int(11) NOT NULL,
  `nombre` varchar(100) COLLATE utf8mb4_unicode_ci NOT NULL,
  `apodos` varchar(45) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `direccion` int(11) NOT NULL,
  `referencias` varchar(100) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `telefono` varchar(10) COLLATE utf8mb4_unicode_ci DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Volcado de datos para la tabla `tb_clientes`
--

INSERT INTO `tb_clientes` (`IDCliente`, `nombre`, `apodos`, `direccion`, `referencias`, `telefono`) VALUES
(1, 'Marino Lozano Hernández', 'El chefes', 47, 'Vive frente a la chaluperia doña bofe', ''),
(2, 'Maxwell Moctezuma Aviles', 'el cacas', 71, 'por el puente', '');

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `tb_consultas`
--

CREATE TABLE `tb_consultas` (
  `IDConsulta` int(11) NOT NULL,
  `IDCliente` int(11) NOT NULL,
  `descripcion` varchar(250) COLLATE utf8mb4_unicode_ci NOT NULL,
  `fechaRegistro` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `fechaProgramada` datetime DEFAULT NULL,
  `estado` tinyint(4) NOT NULL DEFAULT '0',
  `prioridad` tinyint(4) NOT NULL DEFAULT '0',
  `cuentaTotal` float NOT NULL DEFAULT '0',
  `cuentaPagada` float NOT NULL DEFAULT '0',
  `recepcionista` varchar(50) COLLATE utf8mb4_unicode_ci NOT NULL,
  `veterinario` varchar(50) COLLATE utf8mb4_unicode_ci DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Volcado de datos para la tabla `tb_consultas`
--

INSERT INTO `tb_consultas` (`IDConsulta`, `IDCliente`, `descripcion`, `fechaRegistro`, `fechaProgramada`, `estado`, `prioridad`, `cuentaTotal`, `cuentaPagada`, `recepcionista`, `veterinario`) VALUES
(1, 1, 'Castrar un puerco\r\n', '2019-08-02 13:36:40', NULL, 0, 0, 0, 0, 'admin', NULL);

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `tb_direcciones`
--

CREATE TABLE `tb_direcciones` (
  `IDDireccion` int(11) NOT NULL,
  `municipio` varchar(100) COLLATE utf8mb4_unicode_ci NOT NULL,
  `comunidad` varchar(100) COLLATE utf8mb4_unicode_ci NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Volcado de datos para la tabla `tb_direcciones`
--

INSERT INTO `tb_direcciones` (`IDDireccion`, `municipio`, `comunidad`) VALUES
(1, 'San Salvador', 'Bocaja'),
(2, 'San Salvador', 'Bominthza'),
(3, 'San Salvador', 'Boxaxni'),
(4, 'San Salvador', 'Boxtha Chico'),
(5, 'San Salvador', 'Bóxtha Chico'),
(6, 'San Salvador', 'Casa Blanca'),
(7, 'San Salvador', 'Casa Grande'),
(8, 'San Salvador', 'Caxuxi'),
(9, 'San Salvador', 'Cañada Grande'),
(10, 'San Salvador', 'Cerro Blanco'),
(11, 'San Salvador', 'Chichimecas'),
(12, 'San Salvador', 'Demacu'),
(13, 'San Salvador', 'Dengandhó de Juárez'),
(14, 'San Salvador', 'Dextho de Victoria'),
(15, 'San Salvador', 'Déxtho de Victoria'),
(16, 'San Salvador', 'Ejido Santa Teresa (El Tablón)'),
(17, 'San Salvador', 'El Bondho'),
(18, 'San Salvador', 'El Cerrito'),
(19, 'San Salvador', 'El Colorado'),
(20, 'San Salvador', 'El Durazno (El Durazno de Flores Magón)'),
(21, 'San Salvador', 'El Fresno'),
(22, 'San Salvador', 'El Gómez'),
(23, 'San Salvador', 'El Mezquital'),
(24, 'San Salvador', 'El Mothé'),
(25, 'San Salvador', 'El Olvera'),
(26, 'San Salvador', 'El Puerto Lázaro Cárdenas'),
(27, 'San Salvador', 'El Rodrigo'),
(28, 'San Salvador', 'El Tablón'),
(29, 'San Salvador', 'Francisco Villa'),
(30, 'San Salvador', 'Herminia Olguín Díaz'),
(31, 'San Salvador', 'La Flor'),
(32, 'San Salvador', 'La Hacienda'),
(33, 'San Salvador', 'La Palma'),
(34, 'San Salvador', 'Lagunilla'),
(35, 'San Salvador', 'Leandro Valle'),
(36, 'San Salvador', 'Media Luna [Fraccionamiento]'),
(37, 'San Salvador', 'Pacheco de Allende'),
(38, 'San Salvador', 'Pacheco Leandro Valle'),
(39, 'San Salvador', 'Poxindeje de Morelos'),
(40, 'San Salvador', 'Quemtha'),
(41, 'San Salvador', 'El Rincón'),
(42, 'San Salvador', 'San Antonio Abad'),
(43, 'San Salvador', 'San Antonio Zaragoza'),
(44, 'San Salvador', 'San José Doxey'),
(45, 'San Salvador', 'San Miguel Acambay'),
(46, 'San Salvador', 'San Salvador'),
(47, 'San Salvador', 'Santa María Amajac'),
(48, 'San Salvador', 'Teofani'),
(49, 'San Salvador', 'Tothie'),
(50, 'San Salvador', 'Tothie (Tothie de Rojo Gómez)'),
(51, 'San Salvador', 'Vixtha de Madero'),
(52, 'San Salvador', 'Xuchitlán'),
(53, 'Actopan', '2 Cerritos'),
(54, 'Actopan', 'Actopan'),
(55, 'Actopan', 'Actopan Centro'),
(56, 'Actopan', 'Benito Juárez'),
(57, 'Actopan', 'Bothi Baji'),
(58, 'Actopan', 'Bothibaji'),
(59, 'Actopan', 'Boxaxni'),
(60, 'Actopan', 'Canguihuindo'),
(61, 'Actopan', 'Casa Blanca'),
(62, 'Actopan', 'Cañada Chica Antigua'),
(63, 'Actopan', 'Cañada Chica Campo Aéreo'),
(64, 'Actopan', 'Chicavasco'),
(65, 'Actopan', 'Cuarta Manzana Chicavasco (La Ladera Chicavasco)'),
(66, 'Actopan', 'Cuauhtémoc'),
(67, 'Actopan', 'Cuauhtémoc [Colonia]'),
(68, 'Actopan', 'Dajiedhi'),
(69, 'Actopan', 'Daxtha'),
(70, 'Actopan', 'El Apartadero'),
(71, 'Actopan', 'El Boxtha'),
(72, 'Actopan', 'El Daxtha'),
(73, 'Actopan', 'El Huaxtho'),
(74, 'Actopan', 'El Huaxtito'),
(75, 'Actopan', 'El Palomo'),
(76, 'Actopan', 'El Paraje'),
(77, 'Actopan', 'El Porvenir'),
(78, 'Actopan', 'El Senthé'),
(79, 'Actopan', 'Francisco Constancio Azpeitia García'),
(80, 'Actopan', 'Fundición A'),
(81, 'Actopan', 'Fundición B'),
(82, 'Actopan', 'Genaro Guzmán Mayer'),
(83, 'Actopan', 'Huaxto de Emiliano Zapata'),
(84, 'Actopan', 'La Ardilla (Tierras Coloradas)'),
(85, 'Actopan', 'La Escoba'),
(86, 'Actopan', 'La Estancia'),
(87, 'Actopan', 'La Loma'),
(88, 'Actopan', 'La Palma'),
(89, 'Actopan', 'La Peña'),
(90, 'Actopan', 'La Presa'),
(91, 'Actopan', 'La Quinta'),
(92, 'Actopan', 'La Segunda Manzana de Magdalena (El Arco)'),
(93, 'Actopan', 'Las Mecas'),
(94, 'Actopan', 'Los Olivos'),
(95, 'Actopan', 'Magdalena'),
(96, 'Actopan', 'Manzana de Golondrinas'),
(97, 'Actopan', 'Mesa Chica'),
(98, 'Actopan', 'Nuevo Actopan'),
(99, 'Actopan', 'Pabellón Gastronómico'),
(100, 'Actopan', 'Plomosas'),
(101, 'Actopan', 'Pozo Grande'),
(102, 'Actopan', 'Rancho Osorios'),
(103, 'Actopan', 'San Andrés'),
(104, 'Actopan', 'San Andrés Tianguistengo'),
(105, 'Actopan', 'San Diego Canguihuindo'),
(106, 'Actopan', 'San Isidro'),
(107, 'Actopan', 'San Pedrito'),
(108, 'Actopan', 'Santa María Magdalena'),
(109, 'Actopan', 'Saucillo'),
(110, 'Actopan', 'Segunda Manzana Chicavasco (El Pozo)'),
(111, 'Actopan', 'Xideje'),
(112, 'El Arenal', '20 de Noviembre'),
(113, 'El Arenal', '20 de Noviembre [Colonia]'),
(114, 'El Arenal', 'Alfonso Gutiérrez'),
(115, 'El Arenal', 'Antonio Rosales'),
(116, 'El Arenal', 'Antonio Vizcaíno'),
(117, 'El Arenal', 'Casa Blanca (El Camichín)'),
(118, 'El Arenal', 'Cerro de la Cantera'),
(119, 'El Arenal', 'Chimalpa'),
(120, 'El Arenal', 'Chimilpa'),
(121, 'El Arenal', 'Colonia Cuisillos (Huaxtla de Orendain)'),
(122, 'El Arenal', 'Cosahuayán Grande'),
(123, 'El Arenal', 'Crucero de Huaxtla'),
(124, 'El Arenal', 'De Tejas'),
(125, 'El Arenal', 'Don Gil [Granja]'),
(126, 'El Arenal', 'El Arenal'),
(127, 'El Arenal', 'El Arenal [Granja Avícola]'),
(128, 'El Arenal', 'El Bocja'),
(129, 'El Arenal', 'El Guayabo Dos'),
(130, 'El Arenal', 'El Guayabo Uno'),
(131, 'El Arenal', 'El Jiadi'),
(132, 'El Arenal', 'El Llano'),
(133, 'El Arenal', 'El Meje'),
(134, 'El Arenal', 'El Novillero (El Polvorín)'),
(135, 'El Arenal', 'El Ojua'),
(136, 'El Arenal', 'El Paje'),
(137, 'El Arenal', 'El Palo Verde'),
(138, 'El Arenal', 'El Panchote'),
(139, 'El Arenal', 'El Pinar [Granja]'),
(140, 'El Arenal', 'El Polvorín'),
(141, 'El Arenal', 'El Puerto de San Pedro'),
(142, 'El Arenal', 'El Rincón'),
(143, 'El Arenal', 'El Rincón'),
(144, 'El Arenal', 'El Roble'),
(145, 'El Arenal', 'El Sabino'),
(146, 'El Arenal', 'Emiliano Zapata'),
(147, 'El Arenal', 'Empalme de Orendain (Potrero la Presa)'),
(148, 'El Arenal', 'Fray Francisco'),
(149, 'El Arenal', 'Guadalupe Ibarra'),
(150, 'El Arenal', 'Haciendas de Huaxtla'),
(151, 'El Arenal', 'Huaxtla'),
(152, 'El Arenal', 'Huerta las Hiedras'),
(153, 'El Arenal', 'Huertas el Zamorano [Asociación de Propietarios y Colonos]'),
(154, 'El Arenal', 'La Atarjea'),
(155, 'El Arenal', 'La Azteca'),
(156, 'El Arenal', 'La Cantera'),
(157, 'El Arenal', 'La Cima [Fraccionamiento]'),
(158, 'El Arenal', 'La Garita (La Mina)'),
(159, 'El Arenal', 'La Laguna Colorada'),
(160, 'El Arenal', 'La Loma'),
(161, 'El Arenal', 'La Loma'),
(162, 'El Arenal', 'La Manzana Uno'),
(163, 'El Arenal', 'La Mesa'),
(164, 'El Arenal', 'La Minita'),
(165, 'El Arenal', 'La Misión (Los Pitufos)'),
(166, 'El Arenal', 'La Sala (La Caliente)'),
(167, 'El Arenal', 'La Soledad'),
(168, 'El Arenal', 'La Tapatía [Granja]'),
(169, 'El Arenal', 'Laguna Seca'),
(170, 'El Arenal', 'Las Palmas'),
(171, 'El Arenal', 'Las Peñitas'),
(172, 'El Arenal', 'Las Porquerizas [Granja la Presa]'),
(173, 'El Arenal', 'Las Tortugas'),
(174, 'El Arenal', 'Las Tortugas [Fraccionamiento]'),
(175, 'El Arenal', 'Los Cuates'),
(176, 'El Arenal', 'Los Guayabos'),
(177, 'El Arenal', 'Los Robles'),
(178, 'El Arenal', 'Margarita Maza de Juárez'),
(179, 'El Arenal', 'Ninguno'),
(180, 'El Arenal', 'Ojo de Agua San José Tepenene'),
(181, 'El Arenal', 'Ojo de Agua Santa Rosa'),
(182, 'El Arenal', 'Padre Castro'),
(183, 'El Arenal', 'Peñitas [Granja]'),
(184, 'El Arenal', 'Pomona [Granja]'),
(185, 'El Arenal', 'Primavera [Granja]'),
(186, 'El Arenal', 'Puente de las Tortugas'),
(187, 'El Arenal', 'Puerto del Oro'),
(188, 'El Arenal', 'Rancho Alejandro Torres'),
(189, 'El Arenal', 'Rancho de Trino'),
(190, 'El Arenal', 'Rancho el Durazno'),
(191, 'El Arenal', 'Rancho el Trébol'),
(192, 'El Arenal', 'Rancho el Venado'),
(193, 'El Arenal', 'Rancho la Esmeralda'),
(194, 'El Arenal', 'Rancho la Loma'),
(195, 'El Arenal', 'Rancho las Juntas'),
(196, 'El Arenal', 'Rancho las Pilas'),
(197, 'El Arenal', 'Rancho los Paraísos'),
(198, 'El Arenal', 'Rancho San Francisco'),
(199, 'El Arenal', 'Río Habitad (El Río Contry Club)'),
(200, 'El Arenal', 'San Jerónimo'),
(201, 'El Arenal', 'San José Tepenene'),
(202, 'El Arenal', 'Santa Cruz Del Astillero'),
(203, 'El Arenal', 'Santa Quiteria'),
(204, 'El Arenal', 'Santa Quitería'),
(205, 'El Arenal', 'Santa Rosa'),
(206, 'El Arenal', 'Santa Sofía'),
(207, 'El Arenal', 'Tepenene'),
(208, 'El Arenal', 'Tres Mujeres'),
(209, 'El Arenal', 'Uña de Gato'),
(210, 'El Arenal', 'Villas de Huaxtla'),
(211, 'El Arenal', 'Villas del Arenal'),
(212, 'El Arenal', 'Villas del Arenal'),
(213, 'Francisco I. Madero', 'Arambó'),
(214, 'Francisco I. Madero', 'Barrio el Bravo'),
(215, 'Francisco I. Madero', 'Barrio el Quince'),
(216, 'Francisco I. Madero', 'Barrio los Amigos'),
(217, 'Francisco I. Madero', 'Barrio Nuevo México'),
(218, 'Francisco I. Madero', 'Barrio San Antonio'),
(219, 'Francisco I. Madero', 'Bocamiño'),
(220, 'Francisco I. Madero', 'Compuerta el Trece'),
(221, 'Francisco I. Madero', 'Cuarta Demarcación (Barrio los Violines) [Colonia]'),
(222, 'Francisco I. Madero', 'Dengantzha'),
(223, 'Francisco I. Madero', 'Doctor José G. Parres'),
(224, 'Francisco I. Madero', 'El Horno [Colonia]'),
(225, 'Francisco I. Madero', 'El Hoyo'),
(226, 'Francisco I. Madero', 'El Mendoza'),
(227, 'Francisco I. Madero', 'El Mexe'),
(228, 'Francisco I. Madero', 'El Porvenir'),
(229, 'Francisco I. Madero', 'El Potrero'),
(230, 'Francisco I. Madero', 'El Rancho'),
(231, 'Francisco I. Madero', 'El Represo'),
(232, 'Francisco I. Madero', 'El Rosario'),
(233, 'Francisco I. Madero', 'El Rosario [Colonia]'),
(234, 'Francisco I. Madero', 'El Rosario Tepatepec'),
(235, 'Francisco I. Madero', 'El Tapia'),
(236, 'Francisco I. Madero', 'El Veinte [Colonia]'),
(237, 'Francisco I. Madero', 'El Villano'),
(238, 'Francisco I. Madero', 'Emiliano Zapata (Los Morales) [Colonia]'),
(239, 'Francisco I. Madero', 'Francisco Villa [Colonia]'),
(240, 'Francisco I. Madero', 'Jagüey del Gonzudi'),
(241, 'Francisco I. Madero', 'La Comunidad'),
(242, 'Francisco I. Madero', 'La Cruz'),
(243, 'Francisco I. Madero', 'La Mora'),
(244, 'Francisco I. Madero', 'La Puerta'),
(245, 'Francisco I. Madero', 'Las Coronas'),
(246, 'Francisco I. Madero', 'Las Fuentes'),
(247, 'Francisco I. Madero', 'Los Filtros'),
(248, 'Francisco I. Madero', 'Lázaro Cárdenas'),
(249, 'Francisco I. Madero', 'Lázaro Cárdenas (El Mexe) [Colonia]'),
(250, 'Francisco I. Madero', 'San José Boxay'),
(251, 'Francisco I. Madero', 'San Juan Tepa'),
(252, 'Francisco I. Madero', 'Tepatepec'),
(253, 'Francisco I. Madero', 'Tepeyac [Granja]'),
(254, 'Acatlán', 'Acatlán'),
(255, 'Acaxochitlán', 'Acaxochitlán'),
(256, 'Agua Blanca de Iturbide', 'Agua Blanca de Iturbide'),
(257, 'Ajacuba', 'Ajacuba'),
(258, 'Alfajayucan', 'Alfajayucan'),
(259, 'Almoloya', 'Almoloya'),
(260, 'Apan', 'Apan'),
(261, 'Atitalaquia', 'Atitalaquia'),
(262, 'Atlapexco', 'Atlapexco'),
(263, 'Atotonilco de Tula', 'Atotonilco de Tula'),
(264, 'Atotonilco el Grande', 'Atotonilco el Grande'),
(265, 'Calnali', 'Calnali'),
(266, 'Cardonal', 'Cardonal'),
(267, 'Chapantongo', 'Chapantongo'),
(268, 'Chapulhuacán', 'Chapulhuacán'),
(269, 'Chilcuautla', 'Chilcuautla'),
(270, 'Cuautepec de Hinojosa', 'Cuautepec de Hinojosa'),
(271, 'Eloxochitlán', 'Eloxochitlán'),
(272, 'Emiliano Zapata', 'Emiliano Zapata'),
(273, 'Epazoyucan', 'Epazoyucan'),
(274, 'Huasca de Ocampo', 'Huasca de Ocampo'),
(275, 'Huautla', 'Huautla'),
(276, 'Huazalingo', 'Huazalingo'),
(277, 'Huehuetla', 'Huehuetla'),
(278, 'Huejutla de Reyes', 'Huejutla de Reyes'),
(279, 'Huichapan', 'Huichapan'),
(280, 'Ixmiquilpan', 'Ixmiquilpan'),
(281, 'Jacala de Ledezma', 'Jacala de Ledezma'),
(282, 'Jaltocán', 'Jaltocán'),
(283, 'Juárez Hidalgo', 'Juárez Hidalgo'),
(284, 'La Misión', 'La Misión'),
(285, 'Lolotla', 'Lolotla'),
(286, 'Metepec', 'Metepec'),
(287, 'Metztitlán', 'Metztitlán'),
(288, 'Mineral de la Reforma', 'Mineral de la Reforma'),
(289, 'Mineral del Chico', 'Mineral del Chico'),
(290, 'Mineral del Monte', 'Mineral del Monte'),
(291, 'Mixquiahuala de Juárez', 'Mixquiahuala de Juárez'),
(292, 'Molango de Escamilla', 'Molango de Escamilla'),
(293, 'Nicolás Flores', 'Nicolás Flores'),
(294, 'Nopala de Villagrán', 'Nopala de Villagrán'),
(295, 'Omitlán de Juárez', 'Omitlán de Juárez'),
(296, 'Pachuca de Soto', 'Pachuca de Soto'),
(297, 'Pacula', 'Pacula'),
(298, 'Pisaflores', 'Pisaflores'),
(299, 'Progreso de Obregón', 'Progreso de Obregón'),
(300, 'San Agustín Metzquititlán', 'San Agustín Metzquititlán'),
(301, 'San Agustín Tlaxiaca', 'San Agustín Tlaxiaca'),
(302, 'San Bartolo Tutotepec', 'San Bartolo Tutotepec'),
(303, 'San Felipe Orizatlán', 'San Felipe Orizatlán'),
(304, 'Santiago de Anaya', 'Santiago de Anaya'),
(305, 'Santiago Tulantepec de Lugo Guerrero', 'Santiago Tulantepec de Lugo Guerrero'),
(306, 'Singuilucan', 'Singuilucan'),
(307, 'Tasquillo', 'Tasquillo'),
(308, 'Tecozautla', 'Tecozautla'),
(309, 'Tenango de Doria', 'Tenango de Doria'),
(310, 'Tepeapulco', 'Tepeapulco'),
(311, 'Tepehuacán de Guerrero', 'Tepehuacán de Guerrero'),
(312, 'Tepeji del Río de Ocampo', 'Tepeji del Río de Ocampo'),
(313, 'Tepetitlán', 'Tepetitlán'),
(314, 'Tetepango', 'Tetepango'),
(315, 'Tezontepec de Aldama', 'Tezontepec de Aldama'),
(316, 'Tianguistengo', 'Tianguistengo'),
(317, 'Tizayuca', 'Tizayuca'),
(318, 'Tlahuelilpan', 'Tlahuelilpan'),
(319, 'Tlahuiltepa', 'Tlahuiltepa'),
(320, 'Tlanalapa', 'Tlanalapa'),
(321, 'Tlanchinol', 'Tlanchinol'),
(322, 'Tlaxcoapan', 'Tlaxcoapan'),
(323, 'Tolcayuca', 'Tolcayuca'),
(324, 'Tula de Allende', 'Tula de Allende'),
(325, 'Tulancingo de Bravo', 'Tulancingo de Bravo'),
(326, 'Villa de Tezontepec', 'Villa de Tezontepec'),
(327, 'Xochiatipan', 'Xochiatipan'),
(328, 'Xochicoatlán', 'Xochicoatlán'),
(329, 'Yahualica', 'Yahualica'),
(330, 'Zacualtipán de Ángeles', 'Zacualtipán de Ángeles'),
(331, 'Zapotlán de Juárez', 'Zapotlán de Juárez'),
(332, 'Zempoala', 'Zempoala'),
(333, 'Zimapán', 'Zimapán');

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `tb_empleados`
--

CREATE TABLE `tb_empleados` (
  `user` varchar(50) COLLATE utf8mb4_unicode_ci NOT NULL,
  `password` varchar(100) COLLATE utf8mb4_unicode_ci NOT NULL,
  `nombre` varchar(100) COLLATE utf8mb4_unicode_ci NOT NULL,
  `tipo` enum('ADMINISTRADOR','RECEPCIONISTA','VETERINARIO') COLLATE utf8mb4_unicode_ci NOT NULL,
  `telefono` varchar(10) COLLATE utf8mb4_unicode_ci DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Volcado de datos para la tabla `tb_empleados`
--

INSERT INTO `tb_empleados` (`user`, `password`, `nombre`, `tipo`, `telefono`) VALUES
('admin', 'admin', 'Vladimir Azpeitia Hernández', 'ADMINISTRADOR', '7721486753'),
('samuelah', 'ponitas', 'Samuel Azpeitia Hernández', 'VETERINARIO', '7721041190');

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `tb_inventario`
--

CREATE TABLE `tb_inventario` (
  `codigo` varchar(100) COLLATE utf8mb4_unicode_ci NOT NULL,
  `nombre` varchar(100) COLLATE utf8mb4_unicode_ci NOT NULL,
  `marca` varchar(50) COLLATE utf8mb4_unicode_ci NOT NULL,
  `descripcion` varchar(50) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `tipo` varchar(50) COLLATE utf8mb4_unicode_ci NOT NULL,
  `precioUnitario` float NOT NULL DEFAULT '0',
  `precioPublico` varchar(45) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '0',
  `cantidadDisponible` varchar(45) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '0'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Volcado de datos para la tabla `tb_inventario`
--

INSERT INTO `tb_inventario` (`codigo`, `nombre`, `marca`, `descripcion`, `tipo`, `precioUnitario`, `precioPublico`, `cantidadDisponible`) VALUES
('0290234', 'ASUNTOL', 'DINAVET', '123ML', 'Otros', 290, '340', '0'),
('0334213', 'CLOSANTEL', 'DINAVET', 'Suspension 125ml', 'Material de curación', 239, '289', '4'),
('0923452', 'HOJA DE BISTURI', 'UNLINE', '', 'Material de curación', 30, '0', '12'),
('2331232', 'GUANTES LATEX', 'UNLINE', '', 'Material de curación', 14, '16', '45');

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `tb_pedidos`
--

CREATE TABLE `tb_pedidos` (
  `numero` int(11) NOT NULL,
  `proveedor` varchar(100) COLLATE utf8mb4_unicode_ci NOT NULL,
  `fechaRealizado` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `tb_peticiones`
--

CREATE TABLE `tb_peticiones` (
  `numero` int(11) NOT NULL,
  `empleado` varchar(50) COLLATE utf8mb4_unicode_ci NOT NULL,
  `table` varchar(45) COLLATE utf8mb4_unicode_ci NOT NULL,
  `meta` varchar(45) COLLATE utf8mb4_unicode_ci NOT NULL,
  `ID` varchar(45) COLLATE utf8mb4_unicode_ci NOT NULL,
  `fechaSolicitud` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `fechaAprobada` datetime DEFAULT NULL,
  `descripcion` varchar(250) COLLATE utf8mb4_unicode_ci NOT NULL,
  `estado` tinyint(4) NOT NULL DEFAULT '0'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `tb_proveedores`
--

CREATE TABLE `tb_proveedores` (
  `nombre` varchar(100) COLLATE utf8mb4_unicode_ci NOT NULL,
  `direccion` varchar(100) COLLATE utf8mb4_unicode_ci NOT NULL,
  `telefono` varchar(10) COLLATE utf8mb4_unicode_ci NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `tb_tratamientos`
--

CREATE TABLE `tb_tratamientos` (
  `IDConsulta` int(11) NOT NULL,
  `IDTratamiento` int(11) NOT NULL,
  `descripcion` varchar(200) COLLATE utf8mb4_unicode_ci NOT NULL,
  `precio` float NOT NULL DEFAULT '0',
  `fechaRealizado` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `veterinario` varchar(50) COLLATE utf8mb4_unicode_ci NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Disparadores `tb_tratamientos`
--
DELIMITER $$
CREATE TRIGGER `tgg_tratamientos_BI_customize_autoincrement` BEFORE INSERT ON `tb_tratamientos` FOR EACH ROW BEGIN
	DECLARE aux INTEGER;
    DECLARE maxi INTEGER;
    
    SELECT COUNT(1) INTO aux FROM tb_tratamientos
    WHERE IDConsulta = NEW.IDConsulta;
    
    SELECT MAX(IDTratamiento) INTO maxi FROM tb_tratamientos
    WHERE IDConsulta = NEW.IDConsulta;
    
    IF aux = 0 THEN
    	SET NEW.IDTratamiento = 1;
    ELSEIF aux > 0 THEN
    	SET NEW.IDTratamiento = maxi + 1;
    END IF;
    
END
$$
DELIMITER ;

--
-- Índices para tablas volcadas
--

--
-- Indices de la tabla `lista_medicamentos`
--
ALTER TABLE `lista_medicamentos`
  ADD PRIMARY KEY (`botiquin`,`medicamento`),
  ADD KEY `fk_tb_botiquin_has_tb_inventario_tb_inventario1_idx` (`medicamento`),
  ADD KEY `fk_tb_botiquin_has_tb_inventario_tb_botiquin1_idx` (`botiquin`);

--
-- Indices de la tabla `lista_pedido`
--
ALTER TABLE `lista_pedido`
  ADD PRIMARY KEY (`medicamento`) USING BTREE,
  ADD KEY `fk_tb_inventario_has_tb_pedidos_tb_pedidos1_idx` (`pedido`),
  ADD KEY `fk_tb_inventario_has_tb_pedidos_tb_inventario1_idx` (`medicamento`);

--
-- Indices de la tabla `receta`
--
ALTER TABLE `receta`
  ADD PRIMARY KEY (`IDTratamiento`,`IDConsulta`,`medicamento`),
  ADD KEY `fk_tb_tratamientos_has_tb_inventario_tb_inventario1_idx` (`medicamento`),
  ADD KEY `fk_tb_tratamientos_has_tb_inventario_tb_tratamientos1_idx` (`IDTratamiento`,`IDConsulta`);

--
-- Indices de la tabla `tb_botiquin`
--
ALTER TABLE `tb_botiquin`
  ADD PRIMARY KEY (`numero`),
  ADD KEY `fk_tb_botiquin_tb_empleados1_idx` (`veterinario`);

--
-- Indices de la tabla `tb_clientes`
--
ALTER TABLE `tb_clientes`
  ADD PRIMARY KEY (`IDCliente`),
  ADD KEY `fk_tb_clientes_tb_direcciones_idx` (`direccion`);

--
-- Indices de la tabla `tb_consultas`
--
ALTER TABLE `tb_consultas`
  ADD PRIMARY KEY (`IDConsulta`),
  ADD KEY `fk_tb_consultas_tb_clientes1_idx` (`IDCliente`),
  ADD KEY `fk_tb_consultas_tb_empleados1_idx` (`recepcionista`),
  ADD KEY `fk_tb_consultas_tb_empleados2_idx` (`veterinario`);

--
-- Indices de la tabla `tb_direcciones`
--
ALTER TABLE `tb_direcciones`
  ADD PRIMARY KEY (`IDDireccion`);

--
-- Indices de la tabla `tb_empleados`
--
ALTER TABLE `tb_empleados`
  ADD PRIMARY KEY (`user`);

--
-- Indices de la tabla `tb_inventario`
--
ALTER TABLE `tb_inventario`
  ADD PRIMARY KEY (`codigo`);

--
-- Indices de la tabla `tb_pedidos`
--
ALTER TABLE `tb_pedidos`
  ADD PRIMARY KEY (`numero`),
  ADD KEY `fk_tb_pedidos_tb_proveedores1_idx` (`proveedor`);

--
-- Indices de la tabla `tb_peticiones`
--
ALTER TABLE `tb_peticiones`
  ADD PRIMARY KEY (`numero`),
  ADD KEY `fk_tb_peticiones_tb_empleados1_idx` (`empleado`);

--
-- Indices de la tabla `tb_proveedores`
--
ALTER TABLE `tb_proveedores`
  ADD PRIMARY KEY (`nombre`);

--
-- Indices de la tabla `tb_tratamientos`
--
ALTER TABLE `tb_tratamientos`
  ADD PRIMARY KEY (`IDTratamiento`,`IDConsulta`),
  ADD KEY `fk_tb_tratamiento_tb_tratamiento1_idx` (`IDConsulta`),
  ADD KEY `fk_tb_tratamiento_tb_empleados1_idx` (`veterinario`);

--
-- AUTO_INCREMENT de las tablas volcadas
--

--
-- AUTO_INCREMENT de la tabla `tb_clientes`
--
ALTER TABLE `tb_clientes`
  MODIFY `IDCliente` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=3;
--
-- AUTO_INCREMENT de la tabla `tb_consultas`
--
ALTER TABLE `tb_consultas`
  MODIFY `IDConsulta` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=2;
--
-- AUTO_INCREMENT de la tabla `tb_direcciones`
--
ALTER TABLE `tb_direcciones`
  MODIFY `IDDireccion` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=334;
--
-- AUTO_INCREMENT de la tabla `tb_pedidos`
--
ALTER TABLE `tb_pedidos`
  MODIFY `numero` int(11) NOT NULL AUTO_INCREMENT;
--
-- AUTO_INCREMENT de la tabla `tb_peticiones`
--
ALTER TABLE `tb_peticiones`
  MODIFY `numero` int(11) NOT NULL AUTO_INCREMENT;
--
-- Restricciones para tablas volcadas
--

--
-- Filtros para la tabla `lista_medicamentos`
--
ALTER TABLE `lista_medicamentos`
  ADD CONSTRAINT `fk_tb_botiquin_has_tb_inventario_tb_botiquin1` FOREIGN KEY (`botiquin`) REFERENCES `tb_botiquin` (`numero`) ON DELETE NO ACTION ON UPDATE NO ACTION,
  ADD CONSTRAINT `fk_tb_botiquin_has_tb_inventario_tb_inventario1` FOREIGN KEY (`medicamento`) REFERENCES `tb_inventario` (`codigo`) ON DELETE NO ACTION ON UPDATE NO ACTION;

--
-- Filtros para la tabla `lista_pedido`
--
ALTER TABLE `lista_pedido`
  ADD CONSTRAINT `fk_tb_inventario_has_tb_pedidos_tb_inventario1` FOREIGN KEY (`medicamento`) REFERENCES `tb_inventario` (`codigo`) ON DELETE NO ACTION ON UPDATE NO ACTION,
  ADD CONSTRAINT `fk_tb_inventario_has_tb_pedidos_tb_pedidos1` FOREIGN KEY (`pedido`) REFERENCES `tb_pedidos` (`numero`) ON DELETE NO ACTION ON UPDATE NO ACTION;

--
-- Filtros para la tabla `receta`
--
ALTER TABLE `receta`
  ADD CONSTRAINT `fk_tb_tratamientos_has_tb_inventario_tb_inventario1` FOREIGN KEY (`medicamento`) REFERENCES `tb_inventario` (`codigo`) ON DELETE NO ACTION ON UPDATE NO ACTION,
  ADD CONSTRAINT `fk_tb_tratamientos_has_tb_inventario_tb_tratamientos1` FOREIGN KEY (`IDTratamiento`,`IDConsulta`) REFERENCES `tb_tratamientos` (`IDTratamiento`, `IDConsulta`) ON DELETE NO ACTION ON UPDATE NO ACTION;

--
-- Filtros para la tabla `tb_botiquin`
--
ALTER TABLE `tb_botiquin`
  ADD CONSTRAINT `fk_tb_botiquin_tb_empleados1` FOREIGN KEY (`veterinario`) REFERENCES `tb_empleados` (`user`) ON DELETE NO ACTION ON UPDATE NO ACTION;

--
-- Filtros para la tabla `tb_clientes`
--
ALTER TABLE `tb_clientes`
  ADD CONSTRAINT `fk_tb_clientes_tb_direcciones` FOREIGN KEY (`direccion`) REFERENCES `tb_direcciones` (`IDDireccion`) ON DELETE NO ACTION ON UPDATE NO ACTION;

--
-- Filtros para la tabla `tb_consultas`
--
ALTER TABLE `tb_consultas`
  ADD CONSTRAINT `fk_tb_consultas_tb_clientes1` FOREIGN KEY (`IDCliente`) REFERENCES `tb_clientes` (`IDCliente`) ON DELETE NO ACTION ON UPDATE NO ACTION,
  ADD CONSTRAINT `fk_tb_consultas_tb_empleados1` FOREIGN KEY (`recepcionista`) REFERENCES `tb_empleados` (`user`) ON DELETE NO ACTION ON UPDATE NO ACTION,
  ADD CONSTRAINT `fk_tb_consultas_tb_empleados2` FOREIGN KEY (`veterinario`) REFERENCES `tb_empleados` (`user`) ON DELETE NO ACTION ON UPDATE NO ACTION;

--
-- Filtros para la tabla `tb_pedidos`
--
ALTER TABLE `tb_pedidos`
  ADD CONSTRAINT `fk_tb_pedidos_tb_proveedores1` FOREIGN KEY (`proveedor`) REFERENCES `tb_proveedores` (`nombre`) ON DELETE NO ACTION ON UPDATE NO ACTION;

--
-- Filtros para la tabla `tb_peticiones`
--
ALTER TABLE `tb_peticiones`
  ADD CONSTRAINT `fk_tb_peticiones_tb_empleados1` FOREIGN KEY (`empleado`) REFERENCES `tb_empleados` (`user`) ON DELETE NO ACTION ON UPDATE NO ACTION;

--
-- Filtros para la tabla `tb_tratamientos`
--
ALTER TABLE `tb_tratamientos`
  ADD CONSTRAINT `fk_tb_tratamiento_tb_empleados1` FOREIGN KEY (`veterinario`) REFERENCES `tb_empleados` (`user`) ON DELETE NO ACTION ON UPDATE NO ACTION,
  ADD CONSTRAINT `fk_tb_tratamiento_tb_tratamiento1` FOREIGN KEY (`IDConsulta`) REFERENCES `tb_consultas` (`IDConsulta`) ON DELETE NO ACTION ON UPDATE NO ACTION;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
