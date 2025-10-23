-- =========================
-- CONEXIÓN 1 (VENTANA A)
-- =========================

USE concesionaria;

-- 0) Confirmar que esta sesión es distinta de la otra
SELECT CONNECTION_ID() AS conn1_id;

-- 1) Verificar motor InnoDB
SHOW TABLE STATUS LIKE 'vendedor';

-- 2) Verificar que haya PK
SHOW CREATE TABLE vendedor;

-- 3) Verificar aislamiento y autocommit
SELECT @@transaction_isolation AS iso, @@autocommit AS ac;

/* =========================================================
   ESCENARIO A: BLOQUEO EXCLUSIVO Y ESPERA (sin deadlock)
   - Ejecutá estas 3 líneas en CONEXIÓN 1.
   - NO hagas COMMIT hasta que la Conexión 2 haya lanzado su UPDATE.
   ========================================================= */
SET autocommit = 0;
SET SESSION TRANSACTION ISOLATION LEVEL REPEATABLE READ; -- o READ COMMITTED
START TRANSACTION;

-- Toma X-lock sobre id_vendedor = 1
UPDATE vendedor
SET activo = 0
WHERE id_vendedor = 1;
COMMIT;
-- >>> AHORA no ejecutes nada más acá. Volvé a esta conexión para hacer COMMIT
-- >>> después de lanzar el UPDATE de la Conexión 2 en el Escenario A.

/* =========================================================
   ESCENARIO B: DEADLOCK CLÁSICO (dos filas, orden inverso)
   - Solo cuando empieces el Escenario B.
   - Ejecutá estas 3 líneas en CONEXIÓN 1 y no comites.
   ========================================================= */

-- (cuando vayas a probar deadlock, ejecutá estas)
SET autocommit = 0;
START TRANSACTION;

-- X-lock sobre la fila id=1
UPDATE vendedor
SET activo = 0
WHERE id_vendedor = 1;

-- AHORA, volvé a CONEXIÓN 2 para que haga el UPDATE sobre id=2.
-- LUEGO, en esta CONEXIÓN 1 pedí la otra fila (esto quedará esperando):
-- (NO LO EJECUTES HASTA QUE CONEXIÓN 2 HAYA ACTUALIZADO id=2)
-- UPDATE vendedor SET activo = 1 WHERE id_vendedor = 2;

/* =========================================================
   ESCENARIO C: LECTURA QUE BLOQUEA vs LECTURA SNAPSHOT
   - Primero toma X-lock sobre id=2
   ========================================================= */

-- (Cuando pruebes C)
SET autocommit = 0;
START TRANSACTION;

-- X-lock sobre id=2
UPDATE vendedor
SET activo = 0
WHERE id_vendedor = 2;

-- Mantener sin COMMIT para que la Conexión 2 pruebe:
--   1) SELECT ... (no bloquea)
--   2) SELECT ... FOR UPDATE (bloquea)
-- Cuando termines, cierra:
-- COMMIT;
