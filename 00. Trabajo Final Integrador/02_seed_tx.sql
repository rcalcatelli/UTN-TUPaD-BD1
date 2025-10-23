-- ====== PAGOS  ======

-- PAGO 1: 40%..80%
INSERT INTO pago (id_venta, fecha_pago, metodo_pago, importe_pago, estado_pago, referencia_pago)
SELECT
  v.id_venta,
  DATE_ADD(v.fecha_venta, INTERVAL (v.id_venta % 10) DAY),
  ELT((v.id_venta % 4)+1, 'EFECTIVO','TRANSFERENCIA','TARJETA','CHEQUE')       AS metodo_pago,
  ROUND(v.precio_final * (0.4 + ((v.id_venta % 41)/100.0)), 2)                  AS importe_pago,
  'APLICADO'                                                                    AS estado_pago,
  CONCAT('P1-', v.id_venta)                                                     AS referencia_pago
FROM venta v;

-- PAGO 2: ~50% de ventas, apunta al 95% acumulado
INSERT INTO pago (id_venta, fecha_pago, metodo_pago, importe_pago, estado_pago, referencia_pago)
SELECT
  v.id_venta,
  DATE_ADD(v.fecha_venta, INTERVAL (10 + (v.id_venta % 20)) DAY),
  ELT(((v.id_venta+1) % 4)+1, 'EFECTIVO','TRANSFERENCIA','TARJETA','CHEQUE')   AS metodo_pago,
  GREATEST(0.01, ROUND(v.precio_final * 0.95 - (
      SELECT COALESCE(SUM(p.importe_pago),0) FROM pago p WHERE p.id_venta = v.id_venta AND p.estado_pago='APLICADO'
  ), 2))                                                                        AS importe_pago,
  'APLICADO'                                                                    AS estado_pago,
  CONCAT('P2-', v.id_venta)                                                     AS referencia_pago
FROM venta v
WHERE v.id_venta % 2 = 0;

-- PAGO 3: ~25% de ventas, cierra total exacto (sin exceder)
INSERT INTO pago (id_venta, fecha_pago, metodo_pago, importe_pago, estado_pago, referencia_pago)
SELECT
  v.id_venta,
  DATE_ADD(v.fecha_venta, INTERVAL (30 + (v.id_venta % 30)) DAY),
  ELT(((v.id_venta+2) % 4)+1, 'EFECTIVO','TRANSFERENCIA','TARJETA','CHEQUE')   AS metodo_pago,
  GREATEST(0.01, ROUND(v.precio_final - (
      SELECT COALESCE(SUM(p.importe_pago),0) FROM pago p WHERE p.id_venta = v.id_venta AND p.estado_pago='APLICADO'
  ), 2))                                                                        AS importe_pago,
  'APLICADO'                                                                    AS estado_pago,
  CONCAT('P3-', v.id_venta)                                                     AS referencia_pago
FROM venta v
WHERE v.id_venta % 4 = 0;
