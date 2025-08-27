-- ============================================
-- ESTRUCTURA ORIGINAL (CON PROBLEMAS)
-- ============================================

CREATE TABLE CLIENTES (
    id_cliente INT PRIMARY KEY,
    nombre VARCHAR(100) NOT NULL,
    email VARCHAR(100) UNIQUE,
    id_localidad INT,
    FOREIGN KEY (id_localidad) REFERENCES LOCALIDADES(id_localidad)
);

CREATE TABLE LOCALIDADES (
    id_localidad INT PRIMARY KEY,
    nombre_provincia VARCHAR(50) NOT NULL
    -- PROBLEMA: Falta nombre_localidad
);

CREATE TABLE VENTAS (
    id_venta INT PRIMARY KEY,
    fecha DATE NOT NULL,
    id_cliente INT,
    total DECIMAL(10,2) NOT NULL,
    FOREIGN KEY (id_cliente) REFERENCES CLIENTES(id_cliente)
);

CREATE TABLE PRODUCTOS (
    id_producto INT PRIMARY KEY,
    descripcion VARCHAR(200) NOT NULL,
    precio DECIMAL(8,2) NOT NULL
);

CREATE TABLE DETALLES_VENTA (
    id_venta INT,
    id_producto INT,
    cantidad INT NOT NULL,
    precio_unitario DECIMAL(8,2) NOT NULL,
    PRIMARY KEY (id_venta, id_producto),
    FOREIGN KEY (id_venta) REFERENCES VENTAS(id_venta),
    FOREIGN KEY (id_producto) REFERENCES PRODUCTOS(id_producto)
);

-- ============================================
-- ESTRUCTURA CORREGIDA (3FN COMPLETA)
-- ============================================

-- Nueva tabla para eliminar dependencia transitiva
CREATE TABLE PROVINCIAS (
    id_provincia INT PRIMARY KEY,
    nombre_provincia VARCHAR(50) NOT NULL
);

-- Tabla LOCALIDADES corregida
CREATE TABLE LOCALIDADES_CORREGIDA (
    id_localidad INT PRIMARY KEY,
    nombre_localidad VARCHAR(100) NOT NULL,
    id_provincia INT,
    FOREIGN KEY (id_provincia) REFERENCES PROVINCIAS(id_provincia)
);

-- Actualizar tabla CLIENTES para usar la nueva estructura
ALTER TABLE CLIENTES 
DROP FOREIGN KEY clientes_ibfk_1;

ALTER TABLE CLIENTES 
ADD FOREIGN KEY (id_localidad) REFERENCES LOCALIDADES_CORREGIDA(id_localidad);

-- ============================================
-- CONSULTA COMPLEJA (ANTES DE DESNORMALIZAR)
-- ============================================

-- Reporte de ventas con múltiples JOINs
SELECT 
    v.id_venta,
    v.fecha,
    c.nombre AS cliente,
    c.email,
    l.nombre_localidad,
    p.nombre_provincia,
    pr.descripcion AS producto,
    dv.cantidad,
    dv.precio_unitario,
    (dv.cantidad * dv.precio_unitario) AS subtotal,
    v.total
FROM VENTAS v
JOIN CLIENTES c ON v.id_cliente = c.id_cliente
JOIN LOCALIDADES_CORREGIDA l ON c.id_localidad = l.id_localidad
JOIN PROVINCIAS p ON l.id_provincia = p.id_provincia
JOIN DETALLES_VENTA dv ON v.id_venta = dv.id_venta
JOIN PRODUCTOS pr ON dv.id_producto = pr.id_producto
WHERE v.fecha >= '2024-01-01';

-- ============================================
-- DESNORMALIZACIÓN PARA REPORTES
-- ============================================

-- Tabla desnormalizada para reportes rápidos
CREATE TABLE REPORTE_VENTAS (
    id_reporte BIGINT AUTO_INCREMENT PRIMARY KEY,
    id_venta INT NOT NULL,
    fecha DATE NOT NULL,
    id_cliente INT NOT NULL,
    nombre_cliente VARCHAR(100) NOT NULL,
    email_cliente VARCHAR(100),
    localidad_cliente VARCHAR(100) NOT NULL,
    provincia_cliente VARCHAR(50) NOT NULL,
    id_producto INT NOT NULL,
    descripcion_producto VARCHAR(200) NOT NULL,
    cantidad INT NOT NULL,
    precio_unitario DECIMAL(8,2) NOT NULL,
    subtotal DECIMAL(10,2) NOT NULL,
    total_venta DECIMAL(10,2) NOT NULL,
    fecha_actualizacion TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    
    -- Índices para optimizar consultas
    INDEX idx_fecha (fecha),
    INDEX idx_cliente (id_cliente),
    INDEX idx_producto (id_producto),
    INDEX idx_fecha_cliente (fecha, id_cliente)
);

-- ============================================
-- VISTA MATERIALIZADA (ALTERNATIVA)
-- ============================================

-- Simularemos con una vista regular
CREATE VIEW vw_reporte_ventas AS
SELECT 
    v.id_venta,
    v.fecha,
    v.id_cliente,
    c.nombre AS nombre_cliente,
    c.email AS email_cliente,
    l.nombre_localidad AS localidad_cliente,
    p.nombre_provincia AS provincia_cliente,
    dv.id_producto,
    pr.descripcion AS descripcion_producto,
    dv.cantidad,
    dv.precio_unitario,
    (dv.cantidad * dv.precio_unitario) AS subtotal,
    v.total AS total_venta
FROM VENTAS v
JOIN CLIENTES c ON v.id_cliente = c.id_cliente
JOIN LOCALIDADES_CORREGIDA l ON c.id_localidad = l.id_localidad
JOIN PROVINCIAS p ON l.id_provincia = p.id_provincia
JOIN DETALLES_VENTA dv ON v.id_venta = dv.id_venta
JOIN PRODUCTOS pr ON dv.id_producto = pr.id_producto;

-- ============================================
-- DATOS DE EJEMPLO PARA PRUEBAS
-- ============================================

-- Insertar provincias
INSERT INTO PROVINCIAS VALUES 
(1, 'Buenos Aires'),
(2, 'Córdoba'),
(3, 'Santa Fe');

-- Insertar localidades
INSERT INTO LOCALIDADES_CORREGIDA VALUES 
(1, 'La Plata', 1),
(2, 'Mar del Plata', 1),
(3, 'Córdoba Capital', 2),
(4, 'Rosario', 3);

-- Insertar clientes
INSERT INTO CLIENTES VALUES 
(1, 'Juan Pérez', 'juan@email.com', 1),
(2, 'María García', 'maria@email.com', 2),
(3, 'Carlos López', 'carlos@email.com', 3);

-- Insertar productos
INSERT INTO PRODUCTOS VALUES 
(1, 'Laptop HP', 1200.00),
(2, 'Mouse Logitech', 25.00),
(3, 'Teclado Mecánico', 80.00);

-- Insertar ventas
INSERT INTO VENTAS VALUES 
(1, '2024-01-15', 1, 1305.00),
(2, '2024-01-16', 2, 105.00),
(3, '2024-01-17', 3, 1280.00);

-- Insertar detalles de venta
INSERT INTO DETALLES_VENTA VALUES 
(1, 1, 1, 1200.00),  -- Juan compra 1 laptop
(1, 2, 1, 25.00),    -- Juan compra 1 mouse
(1, 3, 1, 80.00),    -- Juan compra 1 teclado
(2, 2, 2, 25.00),    -- María compra 2 mouse
(2, 3, 1, 80.00),    -- María compra 1 teclado
(3, 1, 1, 1200.00),  -- Carlos compra 1 laptop
(3, 3, 1, 80.00);    -- Carlos compra 1 teclado

-- ============================================
-- PROCEDIMIENTO PARA ACTUALIZAR TABLA DESNORMALIZADA
-- ============================================

DELIMITER //
CREATE PROCEDURE ActualizarReporteVentas()
BEGIN
    -- Limpiar tabla de reportes
    TRUNCATE TABLE REPORTE_VENTAS;
    
    -- Insertar datos actualizados
    INSERT INTO REPORTE_VENTAS (
        id_venta, fecha, id_cliente, nombre_cliente, email_cliente,
        localidad_cliente, provincia_cliente, id_producto, descripcion_producto,
        cantidad, precio_unitario, subtotal, total_venta
    )
    SELECT 
        v.id_venta,
        v.fecha,
        v.id_cliente,
        c.nombre,
        c.email,
        l.nombre_localidad,
        p.nombre_provincia,
        dv.id_producto,
        pr.descripcion,
        dv.cantidad,
        dv.precio_unitario,
        (dv.cantidad * dv.precio_unitario),
        v.total
    FROM VENTAS v
    JOIN CLIENTES c ON v.id_cliente = c.id_cliente
    JOIN LOCALIDADES_CORREGIDA l ON c.id_localidad = l.id_localidad
    JOIN PROVINCIAS p ON l.id_provincia = p.id_provincia
    JOIN DETALLES_VENTA dv ON v.id_venta = dv.id_venta
    JOIN PRODUCTOS pr ON dv.id_producto = pr.id_producto;
END //
DELIMITER ;

-- ============================================
-- CONSULTAS DE COMPARACIÓN DE RENDIMIENTO
-- ============================================

-- Consulta NORMALIZADA (lenta - 5 JOINs)
SELECT 
    COUNT(*) as total_items,
    SUM(dv.cantidad * dv.precio_unitario) as total_vendido,
    AVG(dv.precio_unitario) as precio_promedio
FROM VENTAS v
JOIN CLIENTES c ON v.id_cliente = c.id_cliente
JOIN LOCALIDADES_CORREGIDA l ON c.id_localidad = l.id_localidad
JOIN PROVINCIAS p ON l.id_provincia = p.id_provincia
JOIN DETALLES_VENTA dv ON v.id_venta = dv.id_venta
JOIN PRODUCTOS pr ON dv.id_producto = pr.id_producto
WHERE v.fecha >= '2024-01-01'
  AND p.nombre_provincia = 'Buenos Aires';

-- Consulta DESNORMALIZADA (rápida - 0 JOINs)
SELECT 
    COUNT(*) as total_items,
    SUM(subtotal) as total_vendido,
    AVG(precio_unitario) as precio_promedio
FROM REPORTE_VENTAS
WHERE fecha >= '2024-01-01'
  AND provincia_cliente = 'Buenos Aires';