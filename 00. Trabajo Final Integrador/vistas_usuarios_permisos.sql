-- ============================================
-- SCRIPT COMPLETO: VISTAS + USUARIOS + PERMISOS
-- Orden correcto de ejecución
-- ============================================

USE concesionaria;

-- ========================================
-- PASO 1: CREAR VISTAS (primero)
-- ========================================

-- Vista 1: Información pública de vendedores (sin pass_hash)
CREATE OR REPLACE VIEW vista_vendedores_publico AS
SELECT 
    v.id_vendedor,
    v.nombre_vendedor,
    v.apellido_vendedor,
    CONCAT(v.nombre_vendedor, ' ', v.apellido_vendedor) AS nombre_completo,
    v.activo,
    v.fecha_ingreso,
    DATEDIFF(CURDATE(), v.fecha_ingreso) AS dias_antiguedad,
    u.username_vendedor,
    u.rol,
    (SELECT COUNT(*) 
     FROM venta vt 
     WHERE vt.id_vendedor = v.id_vendedor 
       AND vt.estado_pago = 'CONFIRMADA') AS total_ventas,
    (SELECT COALESCE(SUM(precio_final), 0)
     FROM venta vt 
     WHERE vt.id_vendedor = v.id_vendedor 
       AND vt.estado_pago = 'CONFIRMADA') AS monto_total_vendido
FROM vendedor v
LEFT JOIN usuario_vendedor u ON v.id_vendedor = u.id_vendedor
WHERE v.activo = TRUE;

-- Vista 2: Resumen de ventas (sin datos personales de clientes)
CREATE OR REPLACE VIEW vista_ventas_resumen AS
SELECT 
    vt.id_venta,
    vt.fecha_venta,
    CONCAT(
        SUBSTRING(c.nombre_cliente, 1, 1), '.', 
        SUBSTRING(c.apellido_cliente, 1, 1), '.'
    ) AS cliente_iniciales,
    CONCAT(v.nombre_vendedor, ' ', v.apellido_vendedor) AS vendedor,
    u.username_vendedor,
    u.rol,
    vh.dominio_vehiculo,
    vh.modelo_vehiculo,
    vh.anio_vehiculo,
    m.nombre AS nombre_marca,
    vt.precio_final,
    vt.estado_pago,
    (SELECT COALESCE(SUM(importe_pago), 0)
     FROM pago p
     WHERE p.id_venta = vt.id_venta
       AND p.estado_pago = 'APLICADO') AS total_pagado,
    (vt.precio_final - 
     (SELECT COALESCE(SUM(importe_pago), 0)
      FROM pago p
      WHERE p.id_venta = vt.id_venta
        AND p.estado_pago = 'APLICADO')) AS saldo_pendiente
FROM venta vt
INNER JOIN cliente c ON vt.id_cliente = c.id_cliente
INNER JOIN vendedor v ON vt.id_vendedor = v.id_vendedor
LEFT JOIN usuario_vendedor u ON v.id_vendedor = u.id_vendedor
INNER JOIN vehiculo vh ON vt.id_vehiculo = vh.id_vehiculo
INNER JOIN marca m ON vh.id_marca = m.id_marca
WHERE vt.estado_pago = 'CONFIRMADA';

-- Vista 3: Vista completa del sistema (solo para gerente y admin)
CREATE OR REPLACE VIEW vista_vendedores_sistema AS
SELECT 
    v.id_vendedor,
    v.nombre_vendedor,
    v.apellido_vendedor,
    CONCAT(v.nombre_vendedor, ' ', v.apellido_vendedor) AS nombre_completo,
    v.activo AS vendedor_activo,
    v.fecha_ingreso,
    DATEDIFF(CURDATE(), v.fecha_ingreso) AS dias_antiguedad,
    u.id_usuario,
    u.username_vendedor,
    u.rol,
    CASE 
        WHEN u.id_usuario IS NULL THEN 'SIN CREDENCIAL'
        WHEN v.activo = FALSE THEN 'INACTIVO'
        ELSE 'OPERATIVO'
    END AS estado_sistema,
    (SELECT COUNT(*) 
     FROM venta vt 
     WHERE vt.id_vendedor = v.id_vendedor 
       AND vt.estado_pago = 'CONFIRMADA') AS total_ventas,
    (SELECT COALESCE(SUM(precio_final), 0)
     FROM venta vt 
     WHERE vt.id_vendedor = v.id_vendedor 
       AND vt.estado_pago = 'CONFIRMADA') AS monto_total_vendido
FROM vendedor v
LEFT JOIN usuario_vendedor u ON v.id_vendedor = u.id_vendedor;

-- Verificar que las vistas se crearon
SELECT 'Vistas creadas correctamente:' AS mensaje;
SHOW FULL TABLES WHERE Table_type = 'VIEW';

-- ========================================
-- PASO 2: ELIMINAR USUARIOS SI EXISTEN
-- ========================================

DROP USER IF EXISTS 'vendedor_app'@'localhost';
DROP USER IF EXISTS 'gerente_app'@'localhost';
DROP USER IF EXISTS 'admin_app'@'localhost';

-- ========================================
-- PASO 3: CREAR USUARIOS
-- ========================================

CREATE USER 'vendedor_app'@'localhost' 
IDENTIFIED BY 'VendApp2025!Secure';

CREATE USER 'gerente_app'@'localhost' 
IDENTIFIED BY 'GerenteApp2025!Secure';

CREATE USER 'admin_app'@'localhost' 
IDENTIFIED BY 'AdminApp2025!Secure';

SELECT 'Usuarios creados correctamente' AS mensaje;

-- ========================================
-- PASO 4: OTORGAR PERMISOS - ROL VENDEDOR
-- ========================================

-- Tablas base
GRANT SELECT ON concesionaria.vendedor TO 'vendedor_app'@'localhost';
GRANT SELECT ON concesionaria.usuario_vendedor TO 'vendedor_app'@'localhost';
GRANT SELECT, INSERT, UPDATE ON concesionaria.cliente TO 'vendedor_app'@'localhost';
GRANT SELECT, INSERT, UPDATE ON concesionaria.perfil_cliente TO 'vendedor_app'@'localhost';
GRANT SELECT, INSERT ON concesionaria.venta TO 'vendedor_app'@'localhost';
GRANT SELECT, INSERT ON concesionaria.pago TO 'vendedor_app'@'localhost';
GRANT SELECT, UPDATE ON concesionaria.vehiculo TO 'vendedor_app'@'localhost';
GRANT SELECT ON concesionaria.marca TO 'vendedor_app'@'localhost';

-- Vistas (ahora SÍ existen)
GRANT SELECT ON concesionaria.vista_vendedores_publico TO 'vendedor_app'@'localhost';
GRANT SELECT ON concesionaria.vista_ventas_resumen TO 'vendedor_app'@'localhost';

SELECT 'Permisos de VENDEDOR otorgados' AS mensaje;

-- ========================================
-- PASO 5: OTORGAR PERMISOS - ROL GERENTE
-- ========================================

-- Tablas base
GRANT SELECT, INSERT, UPDATE ON concesionaria.vendedor TO 'gerente_app'@'localhost';
GRANT SELECT, INSERT, UPDATE, DELETE ON concesionaria.usuario_vendedor TO 'gerente_app'@'localhost';
GRANT SELECT, INSERT, UPDATE, DELETE ON concesionaria.cliente TO 'gerente_app'@'localhost';
GRANT SELECT, INSERT, UPDATE, DELETE ON concesionaria.perfil_cliente TO 'gerente_app'@'localhost';
GRANT SELECT, INSERT, UPDATE ON concesionaria.venta TO 'gerente_app'@'localhost';
GRANT SELECT, INSERT, UPDATE ON concesionaria.pago TO 'gerente_app'@'localhost';
GRANT SELECT, INSERT, UPDATE, DELETE ON concesionaria.vehiculo TO 'gerente_app'@'localhost';
GRANT SELECT, INSERT, UPDATE ON concesionaria.marca TO 'gerente_app'@'localhost';

-- Vistas
GRANT SELECT ON concesionaria.vista_vendedores_publico TO 'gerente_app'@'localhost';
GRANT SELECT ON concesionaria.vista_ventas_resumen TO 'gerente_app'@'localhost';
GRANT SELECT ON concesionaria.vista_vendedores_sistema TO 'gerente_app'@'localhost';

-- Permisos especiales
GRANT CREATE TEMPORARY TABLES ON concesionaria.* TO 'gerente_app'@'localhost';

SELECT 'Permisos de GERENTE otorgados' AS mensaje;

-- ========================================
-- PASO 6: OTORGAR PERMISOS - ROL SUPERADMIN
-- ========================================

GRANT ALL PRIVILEGES ON concesionaria.* TO 'admin_app'@'localhost';
GRANT GRANT OPTION ON concesionaria.* TO 'admin_app'@'localhost';

SELECT 'Permisos de SUPERADMIN otorgados' AS mensaje;

-- ========================================
-- PASO 7: APLICAR CAMBIOS
-- ========================================

FLUSH PRIVILEGES;

SELECT '✅ SISTEMA DE USUARIOS CONFIGURADO CORRECTAMENTE' AS resultado;

-- ========================================
-- VERIFICACIÓN DE PERMISOS
-- ========================================

SELECT '' AS separador;
SELECT '========== VERIFICACIÓN: VENDEDOR ==========' AS info;
SHOW GRANTS FOR 'vendedor_app'@'localhost';

SELECT '' AS separador;
SELECT '========== VERIFICACIÓN: GERENTE ==========' AS info;
SHOW GRANTS FOR 'gerente_app'@'localhost';

SELECT '' AS separador;
SELECT '========== VERIFICACIÓN: SUPERADMIN ==========' AS info;
SHOW GRANTS FOR 'admin_app'@'localhost';

-- ========================================
-- TABLA RESUMEN (Documentación)
-- ========================================

CREATE TABLE IF NOT EXISTS roles_sistema (
    nombre_rol VARCHAR(50) PRIMARY KEY,
    usuario_db VARCHAR(100) NOT NULL,
    descripcion TEXT,
    permisos_resumen TEXT,
    nivel_acceso ENUM('BASICO','INTERMEDIO','TOTAL') NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- Limpiar si existe
TRUNCATE TABLE roles_sistema;

INSERT INTO roles_sistema VALUES
('VENDEDOR', 'vendedor_app@localhost', 
 'Usuario operativo para gestión de ventas y clientes',
 'SELECT mayoría tablas, INSERT/UPDATE clientes/ventas propias',
 'BASICO'),

('GERENTE', 'gerente_app@localhost',
 'Supervisor con acceso a reportes y gestión de personal',
 'CRUD completo excepto DELETE en ventas/pagos históricos',
 'INTERMEDIO'),

('SUPERADMIN', 'admin_app@localhost',
 'Administrador del sistema con control total',
 'ALL PRIVILEGES + gestión de usuarios y estructura',
 'TOTAL');

SELECT '' AS separador;
SELECT '========== RESUMEN DE ROLES ==========' AS info;
SELECT * FROM roles_sistema;

-- ========================================
-- PRUEBAS RÁPIDAS DE VALIDACIÓN
-- ========================================

SELECT '' AS separador;
SELECT '========== PRUEBAS DE VALIDACIÓN ==========' AS info;

-- Test 1: Verificar que las vistas funcionan
SELECT 'Test 1: Vista vendedores públicos' AS prueba;
SELECT COUNT(*) AS registros FROM vista_vendedores_publico;

-- Test 2: Verificar vista de ventas
SELECT 'Test 2: Vista resumen ventas' AS prueba;
SELECT COUNT(*) AS registros FROM vista_ventas_resumen;

-- Test 3: Verificar que los usuarios existen
SELECT 'Test 3: Usuarios creados' AS prueba;
SELECT user, host FROM mysql.user WHERE user LIKE '%_app' ORDER BY user;

SELECT '✅ Configuración completada - Listo para usar' AS resultado_final;