-- Vendedores (id_vendedor AI, nombre_vendedor, apellido_vendedor, activo TINYINT(1), fecha_ingreso DATE)
INSERT INTO vendedor (nombre_vendedor, apellido_vendedor, activo, fecha_ingreso)
SELECT
  ELT((n % 10)+1, 'Laura','Andrés','Paula','Miguel','Carla','Santiago','Noelia','Tomás','Brenda','Javier') AS nombre_vendedor,
  ELT(((n*5)%12)+1,'García','González','Rodríguez','López','Martínez','Pérez','Gómez','Sánchez','Díaz','Fernández','Romero','Suárez') AS apellido_vendedor,
  IF(n % 20 = 0, 0, 1) AS activo,
  DATE_SUB(CURDATE(), INTERVAL (n % 3650) DAY) AS fecha_ingreso  -- últimos ~10 años
FROM seq
WHERE n <= @N_VENDEDORES;

SELECT COUNT(*) AS vendedores_cargados FROM vendedor;