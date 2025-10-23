-- Offsets para evitar duplicados si ya hay clientes cargados
SET @OFF_CLI := COALESCE((SELECT MAX(id_cliente) FROM cliente), 0);

INSERT INTO cliente (nombre_cliente, apellido_cliente, dni_cliente, email_cliente, telefono_cliente, fecha_alta)
SELECT
  ELT((n % 10)+1, 'Ana','Luis','María','Juan','Sofía','Carlos','Lucía','Pedro','Valentina','Diego') AS nombre_cliente,
  ELT(((n*7)%12)+1,'García','González','Rodríguez','López','Martínez','Pérez','Gómez','Sánchez','Díaz','Fernández','Romero','Suárez') AS apellido_cliente,
  -- DNI único de 8 dígitos (prefijo para evitar ceros/a la izquierda)
  LPAD((n + @OFF_CLI) % 100000000, 8, '0') AS dni_cliente,
  -- Email único
  CONCAT('user', (n + @OFF_CLI), '@demo.com') AS email_cliente,
  CONCAT('+54', LPAD((n + @OFF_CLI) % 10000000, 7, '0')) AS telefono_cliente,
  DATE_SUB(CURDATE(), INTERVAL (n % 2000) DAY) AS fecha_alta
FROM seq
WHERE n <= @N_CLIENTES;

SELECT COUNT(*) AS clientes_cargados FROM cliente;