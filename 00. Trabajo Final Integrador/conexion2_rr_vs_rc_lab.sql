-- =========================
-- CONEXIÓN 2 (VENTANA B) - MySQL Workbench
-- Comparación READ COMMITTED vs REPEATABLE READ
-- Bloqueos y deadlocks sobre tablas de prueba
-- =========================

USE concesionaria;

-- 0) Confirmar que esta sesión es distinta de la otra
SELECT CONNECTION_ID() AS conn2_id;

-- 1) Verificar motor InnoDB
SHOW TABLE STATUS LIKE 'vendedor';

-- 2) Verificar estructura y PK
SHOW CREATE TABLE vendedor;

-- 3) Verificar nivel de aislamiento y autocommit
SELECT @@transaction_isolation AS iso, @@autocommit AS ac;

-- =========================================================
-- A) BLOQUEO EXCLUSIVO Y ESPERA (sin deadlock)
--    Ejecutá este UPDATE cuando Conexión 1 ya haya tomado X-lock sobre id=1.
--    Debería QUEDAR ESPERANDO hasta que Conexión 1 haga COMMIT.
-- =========================================================
SET autocommit = 0;
SET SESSION TRANSACTION ISOLATION LEVEL REPEATABLE READ; -- o READ COMMITTED
START TRANSACTION;

-- Intenta la misma fila que bloqueó Conexión 1
UPDATE vendedor
SET activo = 1
WHERE id_vendedor = 1;

-- Cuando Conexión 1 haga COMMIT, esta sentencia continuará.
-- Luego cerrá:
-- COMMIT;

-- =========================================================
-- B) DEADLOCK CLÁSICO (dos filas, orden inverso)
--    1) Ejecutar este bloque en Conexión 2 (no comites).
--    2) Conexión 1 ya bloqueó id=1.
--    3) Pedí ahora la otra fila (id=1) después de que Conexión 1 pida id=2.
-- =========================================================
SET autocommit = 0;
START TRANSACTION;

-- X-lock sobre id=2
UPDATE vendedor SET activo = 0 WHERE id_vendedor = 2;

-- >>> Volvé a Conexión 1 y ejecutá:
-- UPDATE vendedor SET activo = 1 WHERE id_vendedor = 2; (quedará esperando)
-- >>> Luego, ejecutá acá (esto debería detonar el DEADLOCK):
-- UPDATE vendedor SET activo = 1 WHERE id_vendedor = 1;

-- Cerrá lo que haya quedado:
-- ROLLBACK; -- o COMMIT;

-- =========================================================
-- C) LECTURA QUE BLOQUEA vs LECTURA SNAPSHOT
--    Conexión 1 ya retuvo X-lock sobre id=2.
--    Probá ambos SELECT para ver la diferencia.
-- =========================================================

-- (1) Lectura que NO bloquea (snapshot con MVCC)
SELECT id_vendedor, nombre_vendedor, apellido_vendedor, activo
FROM vendedor
WHERE id_vendedor IN (1, 2)
ORDER BY id_vendedor;

-- (2) Lectura que SÍ bloquea (FOR UPDATE)
SET autocommit = 0;
START TRANSACTION;
SELECT *
FROM vendedor
WHERE id_vendedor = 2
FOR UPDATE;
-- Quedará esperando hasta que Conexión 1 haga COMMIT sobre su UPDATE de id=2.
-- COMMIT;

-- =========================================================
-- D) FANTASMAS con lecturas bloqueantes (FOR UPDATE)
--    En REPEATABLE READ, el INSERT dentro del rango debería quedar esperando.
--    En READ COMMITTED, el INSERT suele entrar (sin gap locks).
-- =========================================================

-- RR (bloquea el insert)
SET autocommit = 0;
SET SESSION TRANSACTION ISOLATION LEVEL REPEATABLE READ;
START TRANSACTION;
-- Conexión 1 ya ejecutó el SELECT ... FOR UPDATE sobre el rango 'Z' 0..100
-- Intentá insertar dentro del rango (en RR debería esperar):
INSERT INTO iso_demo2 (categoria, dato) VALUES ('Z', 50);
-- Cuando Conexión 1 haga COMMIT, este INSERT continuará.
-- COMMIT;

-- RC (permite el insert)
SET autocommit = 0;
SET SESSION TRANSACTION ISOLATION LEVEL READ COMMITTED;
START TRANSACTION;
-- Si Conexión 1 vuelve a hacer SELECT ... FOR UPDATE en RC,
-- normalmente el insert ENTRA (sin next-key locks):
INSERT INTO iso_demo2 (categoria, dato) VALUES ('Z', 60);
COMMIT;

-- =========================================================
-- Utilidades y diagnóstico (podés ejecutar cuando quieras)
-- =========================================================
SHOW PROCESSLIST;
SHOW ENGINE INNODB STATUS;

-- MySQL 8+
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
