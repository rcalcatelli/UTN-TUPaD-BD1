
package tpfinaldb;

import java.math.BigDecimal;
import java.sql.*;

public class TransaccionesEjemplo {

    public void ejemplo1_TransaccionExitosa() {
        System.out.println("\n=== EJEMPLO 1: TRANSACCIÓN EXITOSA (COMMIT) ===");
        
        Connection conn = null;
        try {
            conn = DB.get();  
            conn.setAutoCommit(false);
            System.out.println("✓ Transacción iniciada (AutoCommit = false)");

            int idCliente = obtenerIdValido(conn, "SELECT id_cliente FROM cliente LIMIT 1", "id_cliente", 1);
            int idVendedor = obtenerIdValido(conn, "SELECT id_vendedor FROM vendedor LIMIT 1", "id_vendedor", 1);
            int idVehiculo = obtenerIdValido(conn, "SELECT id_vehiculo FROM vehiculo LIMIT 1", "id_vehiculo", 1);
            
            System.out.println("✓ Usando: Cliente=" + idCliente + ", Vendedor=" + idVendedor + ", Vehículo=" + idVehiculo);
            
            System.out.println("→ Preparando inserción de venta...");
            String sqlVenta = "INSERT INTO venta (id_cliente, id_vendedor, id_vehiculo, fecha_venta, precio_final, estado_pago) VALUES (?, ?, ?, NOW(), ?, ?)";
            PreparedStatement psVenta = conn.prepareStatement(sqlVenta, Statement.RETURN_GENERATED_KEYS);
            psVenta.setInt(1, idCliente); 
            psVenta.setInt(2, idVendedor); 
            psVenta.setInt(3, idVehiculo);
            psVenta.setBigDecimal(4, new BigDecimal("25000.00"));
            psVenta.setString(5, "PENDIENTE");
            
            System.out.println("→ Ejecutando INSERT venta...");
            int filasVenta = psVenta.executeUpdate();
            System.out.println("✓ Venta insertada: " + filasVenta + " fila(s)");

            long idVenta = -1;
            ResultSet rsKeys = psVenta.getGeneratedKeys();
            if (rsKeys.next()) {
                idVenta = rsKeys.getLong(1);
                System.out.println("✓ ID de venta generado: " + idVenta);
            }

            System.out.println("→ Preparando inserción de pago...");
            String sqlPago = "INSERT INTO pago (id_venta, metodo_pago, importe_pago) VALUES (?, ?, ?)";
            PreparedStatement psPago = conn.prepareStatement(sqlPago);
            psPago.setLong(1, idVenta);
            psPago.setString(2, "EFECTIVO");
            psPago.setBigDecimal(3, new BigDecimal("25000.00"));
            
            int filasPago = psPago.executeUpdate();
            System.out.println("✓ Pago insertado: " + filasPago + " fila(s)");
            
            conn.commit();
            System.out.println("✓ COMMIT ejecutado - Transacción confirmada exitosamente");
            
            System.out.println("\n→ VERIFICACIÓN POST-COMMIT:");
            String sqlVerificar = "SELECT v.id_venta, v.precio_final, p.id_pago, p.importe_pago " +
                                 "FROM venta v LEFT JOIN pago p ON v.id_venta = p.id_venta " +
                                 "WHERE v.id_venta = ?";
            PreparedStatement psVerificar = conn.prepareStatement(sqlVerificar);
            psVerificar.setLong(1, idVenta);
            ResultSet rsVerificar = psVerificar.executeQuery();
            if (rsVerificar.next()) {
                System.out.printf("  Venta #%d: $%.2f | Pago #%d: $%.2f%n",
                    rsVerificar.getLong("id_venta"),
                    rsVerificar.getBigDecimal("precio_final"),
                    rsVerificar.getLong("id_pago"),
                    rsVerificar.getBigDecimal("importe_pago"));
            }
            rsVerificar.close();
            psVerificar.close();
            
            rsKeys.close();
            psVenta.close();
            psPago.close();
            
        } catch (Exception e) {
            System.err.println("✗ Error en la transacción: " + e.getMessage());
            try {
                if (conn != null) {
                    conn.rollback();
                    System.out.println("✓ ROLLBACK ejecutado - Transacción revertida");
                }
            } catch (SQLException rollbackEx) {
                System.err.println("✗ Error en ROLLBACK: " + rollbackEx.getMessage());
            }
        } finally {
            try {
                if (conn != null) {
                    conn.setAutoCommit(true);
                    conn.close();
                }
            } catch (SQLException e) {
                System.err.println("✗ Error cerrando conexión: " + e.getMessage());
            }
        }
    }

    public void ejemplo2_TransaccionFallida() {
        System.out.println("\n=== EJEMPLO 2: TRANSACCIÓN FALLIDA (ROLLBACK) ===");
        
        Connection conn = null;
        try {
            conn = DB.get();
           
            conn.setAutoCommit(false);
            System.out.println("✓ Transacción iniciada");

            int idCliente = obtenerIdValido(conn, "SELECT id_cliente FROM cliente LIMIT 1", "id_cliente", 1);
            int idVendedor = obtenerIdValido(conn, "SELECT id_vendedor FROM vendedor LIMIT 1", "id_vendedor", 1);
            int idVehiculo = obtenerIdValido(conn, "SELECT id_vehiculo FROM vehiculo LIMIT 1", "id_vehiculo", 1);

            String sqlVenta = "INSERT INTO venta (id_cliente, id_vendedor, id_vehiculo, fecha_venta, precio_final, estado_pago) VALUES (?, ?, ?, NOW(), ?, ?)";
            PreparedStatement psVenta = conn.prepareStatement(sqlVenta);
            psVenta.setInt(1, idCliente); 
            psVenta.setInt(2, idVendedor); 
            psVenta.setInt(3, idVehiculo); 
            psVenta.setBigDecimal(4, new BigDecimal("30000.00"));
            psVenta.setString(5, "PENDIENTE");
            
            psVenta.executeUpdate();
            System.out.println("✓ Primera operación ejecutada (venta)");
            
            String sqlPago = "INSERT INTO pago (id_venta, metodo_pago, importe_pago) VALUES (?, ?, ?)";
            PreparedStatement psPago = conn.prepareStatement(sqlPago);
            psPago.setInt(1, 99999);
            psPago.setString(2, "TARJETA");
            psPago.setBigDecimal(3, new BigDecimal("30000.00"));
            
            psPago.executeUpdate();
            System.out.println("✓ Segunda operación ejecutada (pago)");

            conn.commit();
            System.out.println("✓ COMMIT ejecutado");
            
            psVenta.close();
            psPago.close();
            
        } catch (SQLException e) {
            System.err.println("✗ Error SQL detectado: " + e.getMessage());
            try {
                if (conn != null) {
                    conn.rollback();
                    System.out.println("✓ ROLLBACK ejecutado - Todas las operaciones revertidas");
                    
                    System.out.println("\n→ VERIFICACIÓN POST-ROLLBACK:");
                    String sqlVerificar = "SELECT COUNT(*) as total FROM venta " +
                                         "WHERE id_cliente = ? AND precio_final = 30000.00 " +
                                         "AND fecha_venta > DATE_SUB(NOW(), INTERVAL 1 MINUTE)";
                    PreparedStatement psVerificar = conn.prepareStatement(sqlVerificar);
                    psVerificar.setInt(1, obtenerIdValido(conn, "SELECT id_cliente FROM cliente LIMIT 1", "id_cliente", 1));
                    ResultSet rsVerificar = psVerificar.executeQuery();
                    if (rsVerificar.next()) {
                        int total = rsVerificar.getInt("total");
                        System.out.println("  Ventas de $30000 insertadas: " + total + " (debe ser 0)");
                        if (total == 0) {
                            System.out.println("  ✓ CORRECTO: La venta fue revertida por el ROLLBACK");
                        }
                    }
                    rsVerificar.close();
                    psVerificar.close();
                }
            } catch (SQLException rollbackEx) {
                System.err.println("✗ Error en ROLLBACK: " + rollbackEx.getMessage());
            }
        } catch (Exception e) {
            System.err.println("✗ Error general: " + e.getMessage());
        } finally {
            try {
                if (conn != null) {
                    conn.setAutoCommit(true);
                    conn.close();
                }
            } catch (SQLException e) {
                System.err.println("✗ Error cerrando conexión: " + e.getMessage());
            }
        }
    }

    public void ejemplo3_TransaccionConSavepoints() {
        System.out.println("\n=== EJEMPLO 3: TRANSACCIÓN CON SAVEPOINTS ===");
        
        Connection conn = null;
        Savepoint savepoint1 = null;
        Savepoint savepoint2 = null;
        
        try {
            conn = DB.get();

            conn.setAutoCommit(false);
            System.out.println("✓ Transacción iniciada");

            int idCliente = obtenerIdValido(conn, "SELECT id_cliente FROM cliente LIMIT 1, 1", "id_cliente", 1);
            int idVendedor = obtenerIdValido(conn, "SELECT id_vendedor FROM vendedor LIMIT 1", "id_vendedor", 1);
            int idVehiculo = obtenerIdValido(conn, "SELECT id_vehiculo FROM vehiculo LIMIT 1", "id_vehiculo", 1);

            String sql = "INSERT INTO venta (id_cliente, id_vendedor, id_vehiculo, fecha_venta, precio_final, estado_pago) VALUES (?, ?, ?, NOW(), ?, ?)";
            PreparedStatement ps = conn.prepareStatement(sql);
            ps.setInt(1, idCliente);
            ps.setInt(2, idVendedor);
            ps.setInt(3, idVehiculo);
            ps.setBigDecimal(4, new BigDecimal("20000.00"));
            ps.setString(5, "PENDIENTE");
            ps.executeUpdate();
            System.out.println("✓ Primera venta insertada");

            savepoint1 = conn.setSavepoint("savepoint1");
            System.out.println("✓ Savepoint1 creado");

            ps.setInt(1, 4);
            ps.setInt(2, 1);
            ps.setInt(3, 1);
            ps.setBigDecimal(4, new BigDecimal("22000.00"));
            ps.setString(5, "PENDIENTE");
            ps.executeUpdate();
            System.out.println("✓ Segunda venta insertada");

            savepoint2 = conn.setSavepoint("savepoint2");
            System.out.println("✓ Savepoint2 creado");

            try {
                ps.setInt(1, 999999);
                ps.setInt(2, 1);
                ps.setInt(3, 1);
                ps.setBigDecimal(4, new BigDecimal("25000.00"));
                ps.setString(5, "PENDIENTE");
                ps.executeUpdate();
                System.out.println("✓ Tercera venta insertada");
            } catch (SQLException e) {
                System.err.println("✗ Error en tercera operación: " + e.getMessage());
                conn.rollback(savepoint2);
                System.out.println("✓ Rollback al savepoint2 - tercera operación cancelada");
            }
            conn.commit();
            System.out.println("✓ COMMIT ejecutado - Transacción finalizada");
            
            ps.close();
            
        } catch (Exception e) {
            System.err.println("✗ Error en transacción: " + e.getMessage());
            try {
                if (conn != null) {
                    conn.rollback();
                    System.out.println("✓ ROLLBACK completo ejecutado");
                }
            } catch (SQLException rollbackEx) {
                System.err.println("✗ Error en ROLLBACK: " + rollbackEx.getMessage());
            }
        } finally {
            try {
                if (conn != null) {
                    conn.setAutoCommit(true);
                    conn.close();
                }
            } catch (SQLException e) {
                System.err.println("✗ Error cerrando conexión: " + e.getMessage());
            }
        }
    }
    public void ejemplo4_TransaccionManualSQL() {
        System.out.println("\n=== EJEMPLO 4: TRANSACCIÓN MANUAL CON SQL ===");
        
        Connection conn = null;
        Statement stmt = null;
        
        try {
            conn = DB.get();
            stmt = conn.createStatement();

            int idCliente1 = obtenerIdValido(conn, "SELECT id_cliente FROM cliente LIMIT 1", "id_cliente", 1);
            int idCliente2 = obtenerIdValido(conn, "SELECT id_cliente FROM cliente LIMIT 1, 1", "id_cliente", 2);
            int idVendedor = obtenerIdValido(conn, "SELECT id_vendedor FROM vendedor LIMIT 1", "id_vendedor", 1);
            int idVehiculo = obtenerIdValido(conn, "SELECT id_vehiculo FROM vehiculo LIMIT 1", "id_vehiculo", 1);

            stmt.execute("START TRANSACTION");
            System.out.println("✓ START TRANSACTION ejecutado");

            String sql1 = "INSERT INTO venta (id_cliente, id_vendedor, id_vehiculo, fecha_venta, precio_final, estado_pago) " +
                         "VALUES (" + idCliente1 + ", " + idVendedor + ", " + idVehiculo + ", NOW(), 28000.00, 'PENDIENTE')";
            int rows1 = stmt.executeUpdate(sql1);
            System.out.println("✓ Operación 1 ejecutada: " + rows1 + " fila(s)");

            String sql2 = "INSERT INTO venta (id_cliente, id_vendedor, id_vehiculo, fecha_venta, precio_final, estado_pago) " +
                         "VALUES (" + idCliente2 + ", " + idVendedor + ", " + idVehiculo + ", NOW(), 32000.00, 'PENDIENTE')";
            int rows2 = stmt.executeUpdate(sql2);
            System.out.println("✓ Operación 2 ejecutada: " + rows2 + " fila(s)");

            ResultSet rs = stmt.executeQuery("SELECT COUNT(*) as total FROM venta WHERE id_cliente IN (" + idCliente1 + ", " + idCliente2 + ") AND estado_pago = 'PENDIENTE'");
            if (rs.next()) {
                System.out.println("✓ Registros pendientes en transacción: " + rs.getInt("total"));
            }
            rs.close();

            stmt.execute("COMMIT");
            System.out.println("✓ COMMIT ejecutado - Cambios confirmados");     
        } catch (SQLException e) {
            System.err.println("✗ Error SQL: " + e.getMessage());
            try {
                if (stmt != null) {
                    stmt.execute("ROLLBACK");
                    System.out.println("✓ ROLLBACK ejecutado");
                }
            } catch (SQLException rollbackEx) {
                System.err.println("✗ Error en ROLLBACK: " + rollbackEx.getMessage());
            }
        } catch (Exception e) {
            System.err.println("✗ Error general: " + e.getMessage());
        } finally {
            try {
                if (stmt != null) stmt.close();
                if (conn != null) conn.close();
            } catch (SQLException e) {
                System.err.println("✗ Error cerrando recursos: " + e.getMessage());
            }
        }
    }

    public static void ejecutarEjemplos() {
        TransaccionesEjemplo ejemplos = new TransaccionesEjemplo();
        
        System.out.println("=== EJEMPLOS DE TRANSACCIONES EN JAVA ===");
        
        try {
            ejemplos.ejemplo1_TransaccionExitosa();
            Thread.sleep(1000);
            
            ejemplos.ejemplo2_TransaccionFallida();
            Thread.sleep(1000);
            
            ejemplos.ejemplo3_TransaccionConSavepoints();
            Thread.sleep(1000);
            
            ejemplos.ejemplo4_TransaccionManualSQL();
            
        } catch (InterruptedException e) {
            Thread.currentThread().interrupt();
        }
        
        System.out.println("\n=== EJEMPLOS COMPLETADOS ===");
    }

    private int obtenerIdValido(Connection conn, String sql, String columna, int valorDefault) {
        try (PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            if (rs.next()) {
                return rs.getInt(columna);
            }
        } catch (SQLException e) {
            System.err.println("⚠ Advertencia: No se pudo obtener " + columna + ", usando valor por defecto: " + valorDefault);
        }
        return valorDefault;
    }
}