-- PAGO 1 (APLICADO)
INSERT INTO pago (id_venta, fecha_pago, metodo_pago, importe_pago, estado_pago, referencia_pago)
SELECT
  ve.id_venta,
  DATE_ADD(ve.fecha_venta, INTERVAL (ve.id_venta % 10) DAY),
  ELT((ve.id_venta % 4)+1, 'EFECTIVO','TRANSFERENCIA','TARJETA','CHEQUE'),
  ROUND(ve.precio_final * (0.4 + ((ve.id_venta % 41)/100.0)), 2),
  'APLICADO',
  CONCAT('P1-', ve.id_venta)
FROM venta ve
WHERE ve.estado_pago = 'CONFIRMADA';

-- PAGO 2 (lleva a ~95%)
INSERT INTO pago (id_venta, fecha_pago, metodo_pago, importe_pago, estado_pago, referencia_pago)
SELECT
  ve.id_venta,
  DATE_ADD(ve.fecha_venta, INTERVAL (10 + (ve.id_venta % 20)) DAY),
  ELT(((ve.id_venta+1) % 4)+1, 'EFECTIVO','TRANSFERENCIA','TARJETA','CHEQUE'),
  GREATEST(0.01, ROUND(ve.precio_final * 0.95 - (
      SELECT COALESCE(SUM(p.importe_pago),0)
      FROM pago p
      WHERE p.id_venta = ve.id_venta
        AND p.estado_pago='APLICADO'
  ), 2)),
  'APLICADO',
  CONCAT('P2-', ve.id_venta)
FROM venta ve
WHERE ve.estado_pago = 'CONFIRMADA'
  AND ve.id_venta % 2 = 0;

-- PAGO 3 (cierra total)
INSERT INTO pago (id_venta, fecha_pago, metodo_pago, importe_pago, estado_pago, referencia_pago)
SELECT
  ve.id_venta,
  DATE_ADD(ve.fecha_venta, INTERVAL (30 + (ve.id_venta % 30)) DAY),
  ELT(((ve.id_venta+2) % 4)+1, 'EFECTIVO','TRANSFERENCIA','TARJETA','CHEQUE'),
  GREATEST(0.01, ROUND(ve.precio_final - (
      SELECT COALESCE(SUM(p.importe_pago),0)
      FROM pago p
      WHERE p.id_venta = ve.id_venta
        AND p.estado_pago='APLICADO'
  ), 2)),
  'APLICADO',
  CONCAT('P3-', ve.id_venta)
FROM venta ve
WHERE ve.estado_pago = 'CONFIRMADA'
  AND ve.id_venta % 4 = 0;
