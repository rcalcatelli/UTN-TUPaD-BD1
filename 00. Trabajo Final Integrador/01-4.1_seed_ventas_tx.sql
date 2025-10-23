-- 1) Elegir vehículos DISPONIBLES y sin venta no anulada (usa ROW_NUMBER para evitar LIMIT @var)
DROP TEMPORARY TABLE IF EXISTS tmp_veh_disp;
CREATE TEMPORARY TABLE tmp_veh_disp (id_vehiculo INT PRIMARY KEY) ENGINE=Memory;

INSERT INTO tmp_veh_disp (id_vehiculo)
SELECT id_vehiculo
FROM (
  SELECT v.id_vehiculo,
         ROW_NUMBER() OVER (ORDER BY v.id_vehiculo) AS rn
  FROM vehiculo v
  WHERE v.estado_vehiculo = 'DISPONIBLE'         -- ← requisito del trigger
    AND NOT EXISTS (
      SELECT 1
      FROM venta ve
      WHERE ve.id_vehiculo = v.id_vehiculo
        AND ve.estado_pago <> 'ANULADA'
    )
) t
WHERE t.rn <= @N_VENTAS;

SELECT COUNT(*) AS tmp_veh_disp_rows FROM tmp_veh_disp;

-- 2) STAGE con todos los campos necesarios (acá sí podemos joinear vehiculo)
DROP TEMPORARY TABLE IF EXISTS tmp_ventas_stage;
CREATE TEMPORARY TABLE tmp_ventas_stage AS
SELECT
  1 + (t.id_vehiculo % @N_CLIENTES)    AS id_cliente,
  1 + (t.id_vehiculo % @N_VENDEDORES)  AS id_vendedor,
  t.id_vehiculo,
  DATE_SUB(NOW(), INTERVAL (t.id_vehiculo % 365) DAY) AS fecha_venta,
  ROUND(v.precio_vehiculo * (1 + ((t.id_vehiculo % 21) - 10)/100), 2) AS precio_final,
  'CONFIRMADA' AS estado_pago,
  NULL        AS observacion_pago
FROM tmp_veh_disp t
JOIN vehiculo v ON v.id_vehiculo = t.id_vehiculo;
