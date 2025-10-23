/* ===============================
   A) Ventas con datos del cliente, vehículo y marca
   =============================== */
SELECT v.id_venta, c.nombre_cliente, c.apellido_cliente,
       m.nombre AS marca, ve.modelo_vehiculo, ve.anio_vehiculo,
       v.precio_final, v.estado_pago
FROM venta v
JOIN cliente c  ON c.id_cliente  = v.id_cliente
JOIN vehiculo ve ON ve.id_vehiculo = v.id_vehiculo
JOIN marca m    ON m.id_marca   = ve.id_marca
LIMIT 10;


/* ===============================
   B) Pagos detallados con método, venta y cliente
   =============================== */
SELECT p.id_pago, p.metodo_pago, p.importe_pago, p.estado_pago,
       v.id_venta, c.nombre_cliente, c.apellido_cliente
FROM pago p
JOIN venta v   ON v.id_venta = p.id_venta
JOIN cliente c ON c.id_cliente = v.id_cliente
WHERE p.estado_pago = 'APLICADO'
ORDER BY p.fecha_pago DESC
LIMIT 10;


/* ===============================
   C) Total vendido por marca y año (solo vehículos vendidos)
   =============================== */
SELECT m.nombre AS marca, ve.anio_vehiculo,
       COUNT(*) AS cant_ventas,
       SUM(v.precio_final) AS total_vendido
FROM venta v
JOIN vehiculo ve ON ve.id_vehiculo = v.id_vehiculo
JOIN marca m     ON m.id_marca = ve.id_marca
GROUP BY m.nombre, ve.anio_vehiculo
HAVING SUM(v.precio_final) > 500000000
ORDER BY total_vendido DESC;


/* ===============================
   D) Clientes que gastaron más que el promedio general de ventas
   =============================== */
SELECT c.id_cliente, c.nombre_cliente, c.apellido_cliente,
       SUM(v.precio_final) AS total_gastado
FROM cliente c
JOIN venta v ON v.id_cliente = c.id_cliente
GROUP BY c.id_cliente, c.nombre_cliente, c.apellido_cliente
HAVING SUM(v.precio_final) >
       (SELECT AVG(precio_final) FROM venta);


/* ===============================
   E) Vista: Detalle de Ventas (con pagos y saldo)
   =============================== */
CREATE OR REPLACE VIEW vw_ventas_detalle AS
SELECT v.id_venta, v.fecha_venta, v.precio_final, v.estado_pago,
       c.nombre_cliente, c.apellido_cliente,
       ve.modelo_vehiculo, ve.anio_vehiculo,
       m.nombre AS marca,
       ven.nombre_vendedor, ven.apellido_vendedor,
       COALESCE(SUM(p.importe_pago),0) AS total_pagado,
       (v.precio_final - COALESCE(SUM(p.importe_pago),0)) AS saldo
FROM venta v
JOIN cliente c  ON c.id_cliente = v.id_cliente
JOIN vehiculo ve ON ve.id_vehiculo = v.id_vehiculo
JOIN marca m    ON m.id_marca = ve.id_marca
JOIN vendedor ven ON ven.id_vendedor = v.id_vendedor
LEFT JOIN pago p  ON p.id_venta = v.id_venta AND p.estado_pago='APLICADO'
GROUP BY v.id_venta, v.fecha_venta, v.precio_final, v.estado_pago,
         c.nombre_cliente, c.apellido_cliente,
         ve.modelo_vehiculo, ve.anio_vehiculo,
         m.nombre, ven.nombre_vendedor, ven.apellido_vendedor;


/* ===============================
   F) Consulta rápida a la vista
   =============================== */
SELECT * 
FROM vw_ventas_detalle
ORDER BY id_venta DESC
LIMIT 10;
