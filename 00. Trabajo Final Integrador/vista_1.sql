-- ============================================
-- VISTA 1: Información pública de vendedores
-- ============================================

CREATE OR REPLACE VIEW vista_vendedores_publico AS
SELECT 
    v.id_vendedor,
    v.nombre_vendedor,
    v.apellido_vendedor,
    CONCAT(v.nombre_vendedor, ' ', v.apellido_vendedor) AS nombre_completo,
    v.activo,
    v.fecha_ingreso,
    DATEDIFF(CURDATE(), v.fecha_ingreso) AS dias_antiguedad,
    -- Credencial: SIN pass_hash (información sensible)
    u.username_vendedor,
    u.rol,
    -- Estadísticas agregadas
    (SELECT COUNT(*) 
     FROM venta vt 
     WHERE vt.id_vendedor = v.id_vendedor 
       AND vt.estado_pago = 'CONFIRMADA') AS total_ventas,
    (SELECT COALESCE(SUM(precio_final), 0)
     FROM venta vt 
     WHERE vt.id_vendedor = v.id_vendedor 
       AND vt.estado_pago = 'CONFIRMADA') AS monto_total_vendido
FROM vendedor v
LEFT JOIN usuario_vendedor u ON v.id_vendedor = u.id_vendedor
WHERE v.activo = TRUE;  -- Solo vendedores activos

-- Uso de la vista
SELECT * FROM vista_vendedores_publico 
ORDER BY total_ventas DESC 
LIMIT 5;