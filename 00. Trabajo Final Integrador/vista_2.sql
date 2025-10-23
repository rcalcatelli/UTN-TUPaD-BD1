-- ============================================
-- VISTA 2: Resumen de ventas (GDPR compliant)
-- ============================================

CREATE OR REPLACE VIEW vista_ventas_resumen AS
SELECT 
    vt.id_venta,
    vt.fecha_venta,
    -- Cliente: SOLO INICIALES (protección GDPR)
    CONCAT(
        SUBSTRING(c.nombre_cliente, 1, 1), '.', 
        SUBSTRING(c.apellido_cliente, 1, 1), '.'
    ) AS cliente_iniciales,
    -- Vendedor: info completa (usuario interno)
    CONCAT(v.nombre_vendedor, ' ', v.apellido_vendedor) AS vendedor,
    u.username_vendedor,
    u.rol,
    -- Vehículo vendido
    vh.dominio_vehiculo,
    vh.modelo_vehiculo,
    vh.anio_vehiculo,
    m.nombre_marca AS marca,
    -- Información financiera
    vt.precio_final,
    vt.estado_pago,
    -- Pagos realizados
    (SELECT COALESCE(SUM(importe_pago), 0)
     FROM pago p
     WHERE p.id_venta = vt.id_venta
       AND p.estado_pago = 'APLICADO') AS total_pagado,
    -- Saldo pendiente
    (vt.precio_final - 
     (SELECT COALESCE(SUM(importe_pago), 0)
      FROM pago p
      WHERE p.id_venta = vt.id_venta
        AND p.estado_pago = 'APLICADO')) AS saldo_pendiente
FROM venta vt
INNER JOIN cliente c ON vt.id_cliente = c.id_cliente
INNER JOIN vendedor v ON vt.id_vendedor = v.id_vendedor
LEFT JOIN usuario_vendedor u ON v.id_vendedor = u.id_vendedor
INNER JOIN vehiculo vh ON vt.id_vehiculo = vh.id_vehiculo
INNER JOIN marca m ON vh.id_marca = m.id_marca
WHERE vt.estado_pago = 'CONFIRMADA';

-- Uso de la vista
SELECT * FROM vista_ventas_resumen
WHERE saldo_pendiente > 0
ORDER BY fecha_venta DESC
LIMIT 10;