-- =========================
-- CONEXIÓN 2 (VENTANA B)
-- =========================

USE concesionaria;

-- 0) Confirmar que esta sesión es distinta de la otra
SELECT CONNECTION_ID() AS conn2_id;

-- 1) Verificar motor InnoDB
SHOW TABLE STATUS LIKE 'vendedor';

-- 2) Verificar que haya PK
SHOW CREATE TABLE vendedor;

-- 3) Verificar aislamiento y autocommit
SELECT @@transaction_isolation AS iso, @@autocommit AS ac;

/* =========================================================
   ESCENARIO A: BLOQUEO EXCLUSIVO Y ESPERA (sin deadlock)
   - Lanza este UPDATE una vez que Conexión 1 haya hecho su UPDATE sobre id=1.
   - Debería QUEDAR ESPERANDO hasta que Conexión 1 haga COMMIT.
   ========================================================= */
SET autocommit = 0;
SET SESSION TRANSACTION ISOLATION LEVEL REPEATABLE READ;
START TRANSACTION;

-- Intenta actualizar la misma fila que bloqueó Conexión 1
UPDATE vendedor
SET activo = 1
WHERE id_vendedor = 1;

-- Cuando Conexión 1 haga COMMIT, esta sentencia debería continuar.
-- Luego cerrá:
-- COMMIT;

/* =========================================================
   ESCENARIO B: DEADLOCK CLÁSICO (dos filas, orden inverso)
   - Ejecutá estas 3 líneas en CONEXIÓN 2 y no comites.
   ========================================================= */

SET autocommit = 0;
START TRANSACTION;

-- X-lock sobre la fila id=2
UPDATE vendedor
SET activo = 0
WHERE id_vendedor = 2;

-- AHORA, volvé a CONEXIÓN 1 para que ejecute:
-- UPDATE vendedor SET activo = 1 WHERE id_vendedor = 2; (quedará esperando)
-- Luego, ejecutá acá en CONEXIÓN 2 (esto detonará el DEADLOCK):
 UPDATE vendedor SET activo = 1 WHERE id_vendedor = 1;

/* =========================================================
   ESCENARIO C: LECTURA QUE BLOQUEA vs LECTURA SNAPSHOT
   - Conexión 1 ya retuvo X-lock sobre id=2.
   - Probá ambos SELECT.
   ========================================================= */

-- (1) Lectura que NO bloquea (snapshot con MVCC)
SELECT id_vendedor, nombre_vendedor, apellido_vendedor, activo
FROM vendedor
WHERE id_vendedor IN (1, 2)
ORDER BY id_vendedor;

-- (2) Lectura que SÍ bloquea (pide lock y espera)
SELECT *
FROM vendedor
WHERE id_vendedor = 2
FOR UPDATE;

-- Cuando Conexión 1 haga COMMIT, este SELECT FOR UPDATE va a continuar.
-- Cerrá la transacción si queda abierta:
-- COMMIT;
