START TRANSACTION;

INSERT INTO cliente (
  nombre_cliente, apellido_cliente, dni_cliente, email_cliente, telefono_cliente, fecha_alta
)
VALUES
  -- inválido: SIN "@"
  ('Carlos','Suárez','00000005','user5demo.com','+540000005','2025-10-07'),
  -- inválido: SIN “.algo” luego del dominio (no cumple el . del regex)
  ('Lucía','Gómez','00000006','user6@demo','+540000006','2025-10-06');

-- Esperado: ERROR 3819 (Check constraint 'cliente_chk_1' is violated)
ROLLBACK;