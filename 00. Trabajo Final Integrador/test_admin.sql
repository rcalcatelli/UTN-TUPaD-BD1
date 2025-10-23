-- Conectar como admin
-- mysql -u admin_app -p concesionaria
-- Password: AdminApp2025!Secure

-- ✅ TODO DEBE FUNCIONAR
SELECT * FROM usuario_vendedor;
DELETE FROM venta WHERE id_venta = 999;
ALTER TABLE marca ADD COLUMN test VARCHAR(10);
ALTER TABLE marca DROP COLUMN test;