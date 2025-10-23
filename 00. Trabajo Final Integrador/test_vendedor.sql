USE concesionaria;

-- Conectar como vendedor
-- mysql -u vendedor_app -p concesionaria
-- Password: VendApp2025!Secure

-- ✅ DEBE FUNCIONAR
SELECT * FROM vista_vendedores_publico LIMIT 5;
SELECT * FROM vehiculo WHERE estado_vehiculo = 'DISPONIBLE' LIMIT 5;

-- ❌ DEBE FALLAR
DELETE FROM venta WHERE id_venta = 1;
-- Error esperado: ERROR 1142 (42000): DELETE command denied

SELECT pass_hash FROM usuario_vendedor LIMIT 1;
-- No debe mostrar el campo o debe dar error