INSERT INTO venta
  (id_cliente, id_vendedor, id_vehiculo, fecha_venta, precio_final, estado_pago, observacion_pago)
SELECT
  id_cliente, id_vendedor, id_vehiculo, fecha_venta, precio_final, estado_pago, observacion_pago
FROM tmp_ventas_stage;

SELECT ROW_COUNT() AS ventas_insertadas;  -- Deberías ver un número grande

