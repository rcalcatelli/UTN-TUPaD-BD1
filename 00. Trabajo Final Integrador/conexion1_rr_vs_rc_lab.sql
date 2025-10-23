-- =========================
-- CONEXIÓN 1 (VENTANA A) - MySQL Workbench
-- Comparación READ COMMITTED vs REPEATABLE READ
-- Bloqueos y deadlocks sobre tablas de prueba
-- =========================

USE concesionaria;

-- 0) Confirmar que esta sesión es distinta de la otra
SELECT CONNECTION_ID() AS conn1_id;

-- 1) Verificar motor InnoDB (debe ser InnoDB para locks por fila)
SHOW TABLE STATUS LIKE 'vendedor';

-- 2) Verificar estructura y PK
SHOW CREATE TABLE vendedor;

-- 3) Verificar nivel de aislamiento y autocommit
SELECT @@transaction_isolation AS iso, @@autocommit AS ac;

-- =========================================================
-- 0) SETUP de tablas de prueba (ejecutar una sola vez)
--    (Podés ejecutar esto en cualquiera de las conexiones)
-- =========================================================
-- Limpieza previa
DROP TABLE IF EXISTS iso_demo;
CREATE TABLE iso_demo (
  id INT PRIMARY KEY,
  valor INT NOT NULL
) ENGINE=InnoDB;

INSERT INTO iso_demo (id, valor) VALUES (1,100);

DROP TABLE IF EXISTS iso_demo2;
CREATE TABLE iso_demo2 (
  id INT AUTO_INCREMENT PRIMARY KEY,
  categoria VARCHAR(10) NOT NULL,
  dato INT NOT NULL
) ENGINE=InnoDB;

INSERT INTO iso_demo2 (categoria, dato) VALUES
  ('A', 10), ('A', 20), ('B', 99);

-- =========================================================
-- A) BLOQUEO EXCLUSIVO Y ESPERA (sin deadlock)
--    1) Ejecutar este bloque EN ESTA CONEXIÓN 1.
--    2) Luego, en Conexión 2, correr el UPDATE sobre id=1.
--    3) Volver aquí y COMMIT para liberar.
-- =========================================================
SET autocommit = 0;
SET SESSION TRANSACTION ISOLATION LEVEL REPEATABLE READ; -- o READ COMMITTED
START TRANSACTION;

-- Toma X-lock sobre la fila 1 en 'vendedor'
UPDATE vendedor
SET activo = 0
WHERE id_vendedor = 1;

-- >>> No hagas COMMIT todavía. Cambiá a Conexión 2 y lanzá su UPDATE.
-- >>> Cuando quieras liberar la espera de Conexión 2, ejecutá COMMIT aquí.
-- COMMIT;

-- =========================================================
-- B) DEADLOCK CLÁSICO (dos filas, orden inverso)
--    1) Ejecutar este bloque EN ESTA CONEXIÓN 1 (no comites).
--    2) En Conexión 2, tomar X-lock sobre id=2.
--    3) Volver aquí y pedir la otra fila (id=2) -> quedará esperando.
--    4) En Conexión 2, pedir id=1 -> debería detonar DEADLOCK (ERROR 1213)
-- =========================================================
SET autocommit = 0;
START TRANSACTION;

-- X-lock sobre id=1
UPDATE vendedor SET activo = 0 WHERE id_vendedor = 1;

-- >>> Volvé a Conexión 2 y ejecutá: UPDATE vendedor SET activo = 0 WHERE id_vendedor = 2;
-- >>> Luego, acá en Conexión 1, ejecutá (de a una sentencia):
-- UPDATE vendedor SET activo = 1 WHERE id_vendedor = 2;

-- Tras el experimento, cerrá:
-- ROLLBACK; -- o COMMIT;

-- =========================================================
-- C) LECTURA QUE BLOQUEA vs LECTURA SNAPSHOT
--    1) Este bloque toma X-lock sobre id=2.
--    2) En Conexión 2, probá SELECT normal (no bloquea) y SELECT ... FOR UPDATE (bloquea).
-- =========================================================
SET autocommit = 0;
START TRANSACTION;

-- X-lock sobre id=2
UPDATE vendedor SET activo = 0 WHERE id_vendedor = 2;

-- >>> En Conexión 2: correr SELECT (normal) y luego SELECT ... FOR UPDATE sobre id=2.
-- >>> Cuando termines, liberá aquí:
-- COMMIT;

-- =========================================================
-- D) FANTASMAS con lecturas bloqueantes (FOR UPDATE)
--    Rango sobre iso_demo2, categoría 'Z'
-- =========================================================

-- Preparación del rango
-- (Ejecutar fuera de transacción)
DELETE FROM iso_demo2 WHERE categoria = 'Z';
INSERT INTO iso_demo2 (categoria, dato) VALUES ('Z', 10), ('Z', 20);

SET autocommit = 0;
SET SESSION TRANSACTION ISOLATION LEVEL REPEATABLE READ;
START TRANSACTION;

-- En RR, FOR UPDATE aplica next-key locks sobre el rango
SELECT * FROM iso_demo2
WHERE categoria = 'Z' AND dato BETWEEN 0 AND 100
FOR UPDATE;

-- >>> En Conexión 2 intentá: INSERT INTO iso_demo2 (categoria, dato) VALUES ('Z', 50);
--     En RR quedará esperando hasta que liberemos.
-- COMMIT;

-- =========================================================
-- Utilidades y diagnóstico (podés ejecutar cuando quieras)
-- =========================================================
-- Ver hilos activos
SHOW PROCESSLIST;

-- Último deadlock (abrí la celda "Status" para ver detalles en Workbench)
SHOW ENGINE INNODB STATUS;

-- Locks y esperas (MySQL 8+)
SELECT * FROM performance_schema.data_locks;
SELECT * FROM performance_schema.data_lock_waits;

-- Reset rápido
ROLLBACK;

-- Estado final de prueba
SELECT * FROM iso_demo;
SELECT categoria, dato FROM iso_demo2 ORDER BY categoria, dato;
SELECT id_vendedor, nombre_vendedor, apellido_vendedor, activo
FROM vendedor
WHERE id_vendedor IN (1,2)
ORDER BY id_vendedor;
