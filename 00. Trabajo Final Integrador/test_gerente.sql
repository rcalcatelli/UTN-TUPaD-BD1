-- Conectar como gerente
-- mysql -u gerente_app -p concesionaria
-- Password: GerenteApp2025!Secure

-- ✅ DEBE FUNCIONAR
SELECT * FROM vista_vendedores_sistema LIMIT 5;
UPDATE vehiculo SET precio_vehiculo = 5000000 WHERE id_vehiculo = 1;

-- ❌ DEBE FALLAR (no puede eliminar ventas históricas)
DELETE FROM venta WHERE id_venta = 1;
-- Error esperado: ERROR 1142 (42000): DELETE command denied