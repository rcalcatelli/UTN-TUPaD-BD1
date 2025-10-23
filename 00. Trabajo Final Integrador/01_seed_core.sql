-- =======================
-- 01_seed_core.sql (seguro)
-- Cargar MARCA y stock de VEHICULO
-- =======================

-- ====== MARCA ======
DROP TABLE IF EXISTS marca;
CREATE TABLE marca (
  id_marca INT AUTO_INCREMENT PRIMARY KEY,
  nombre   VARCHAR(40) NOT NULL UNIQUE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

INSERT INTO marca(nombre) VALUES
('Toyota'),('Ford'),('Chevrolet'),('Volkswagen'),('Renault'),
('Peugeot'),('Fiat'),('Nissan'),('Honda'),('Citroën');

-- ====== VEHICULO ======
-- Columnas reales (según tu DESCRIBE):
--  id_vehiculo (PK), dominio_vehiculo (UNIQUE),
--  estado_vehiculo (ENUM('DISPONIBLE','RESERVADO','VENDIDO')),
--  modelo_vehiculo (VARCHAR), anio_vehiculo (YEAR),
--  precio_vehiculo (DECIMAL), id_cliente (NULL), id_marca (FK)

-- Evitar colisiones de patentes si ya hay datos:
SET @BASE := (SELECT COALESCE(COUNT(*),0) FROM vehiculo);

INSERT INTO vehiculo
  (dominio_vehiculo, estado_vehiculo, modelo_vehiculo, anio_vehiculo, precio_vehiculo, id_cliente, id_marca)
SELECT
  -- Dominio único estilo AA999BB en "base-23" (sin I,O,Q)
  CONCAT(
    ELT((( (n+@BASE)                      ) % 23) + 1, 'A','B','C','D','E','F','G','H','J','K','L','M','N','P','R','S','T','U','V','W','X','Y','Z'),
    ELT((( FLOOR((n+@BASE)       / 23)    ) % 23) + 1, 'A','B','C','D','E','F','G','H','J','K','L','M','N','P','R','S','T','U','V','W','X','Y','Z'),
    LPAD(   FLOOR((n+@BASE) / (23*23))          % 1000 , 3, '0'),
    ELT((( FLOOR((n+@BASE) / (23*23*1000)) ) % 23) + 1, 'A','B','C','D','E','F','G','H','J','K','L','M','N','P','R','S','T','U','V','W','X','Y','Z'),
    ELT((( FLOOR((n+@BASE) / (23*23*1000*23)) ) % 23) + 1, 'A','B','C','D','E','F','G','H','J','K','L','M','N','P','R','S','T','U','V','W','X','Y','Z')
  ) AS dominio_vehiculo,

  -- Estado: más probabilidad de quedar DISPONIBLE
  ELT((n % 3)+1, 'DISPONIBLE','RESERVADO','DISPONIBLE')  AS estado_vehiculo,

  -- Modelo / año / precio
  ELT(((n*17)%8)+1, 'Base','Full','XR','GLi','XEi','Highline','Comfort','Sport') AS modelo_vehiculo,
  (2000 + (n % 25))                    AS anio_vehiculo,   -- 2000..2024
  (3000000 + (n % 100000) * 100)       AS precio_vehiculo, -- 3M..13M aprox

  NULL                                 AS id_cliente,      -- stock inicial sin dueño
  ELT((n % 10)+1, 1,2,3,4,5,6,7,8,9,10) AS id_marca        -- FK a marca

FROM seq
WHERE n <= @N_VEHICULOS;

-- Info rápida
SELECT COUNT(*) AS vehiculos_insertados FROM vehiculo;
