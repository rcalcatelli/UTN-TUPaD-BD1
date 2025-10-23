package tpfinaldb;
import java.math.BigDecimal;
import java.util.Scanner;

public class App {
  public static void main(String[] args) throws Exception {
    try (var cn = DB.get()) {
      try (var st = cn.createStatement(); var rs = st.executeQuery("SELECT CURRENT_USER(), USER()")) {
        if (rs.next()) {
          System.out.println("Conectado como: CURRENT_USER=" + rs.getString(1) + " | USER()=" + rs.getString(2));
        }
      }
    }
    Scanner scanner = new Scanner(System.in);
    while (true) {
      System.out.println("\n=== MENÚ PRINCIPAL ===");
      System.out.println("1. Ejecutar ejemplos de transacciones");
      System.out.println("2. Probar DAO de pagos original");
      System.out.println("3. Listar resumen de ventas");
      System.out.println("4. Buscar venta o pago por ID");
      System.out.println("0. Salir");
      System.out.print("Seleccione una opción: ");
      
      String opcion = scanner.nextLine().trim();
      
      switch (opcion) {
        case "1":
          TransaccionesEjemplo.ejecutarEjemplos();
          break;
          
        case "2":
          probarDAOOriginal();
          break;
          
        case "3":
          System.out.println("\n=== RESUMEN DE VENTAS RECIENTES ===");
          PagoDAO dao = new PagoDAO();
          dao.listarVentasResumen(15);
          break;
          
        case "4":
          buscarPorId(scanner);
          break;
          
        case "0":
          System.out.println("¡Hasta luego!");
          scanner.close();
          return;
          
        default:
          System.out.println("Opción no válida. Intente nuevamente.");
      }
    }
  }
  
  private static void buscarPorId(Scanner scanner) {
    System.out.println("\n=== BUSCAR POR ID ===");
    System.out.println("1. Buscar venta por ID");
    System.out.println("2. Buscar pago por ID");
    System.out.print("Seleccione opción: ");
    
    String subOpcion = scanner.nextLine().trim();
    
    try (var cn = DB.get()) {
      if (subOpcion.equals("1")) {
        System.out.print("Ingrese ID de venta: ");
        int idVenta = Integer.parseInt(scanner.nextLine().trim());
        
        String sql = "SELECT v.id_venta, v.id_cliente, v.id_vendedor, v.id_vehiculo, " +
                     "v.fecha_venta, v.precio_final, v.estado_pago, v.observacion_pago " +
                     "FROM venta v WHERE v.id_venta = ?";
        
        try (var ps = cn.prepareStatement(sql)) {
          ps.setInt(1, idVenta);
          try (var rs = ps.executeQuery()) {
            if (rs.next()) {
              System.out.println("\n✓ VENTA ENCONTRADA:");
              System.out.println("  ID Venta: " + rs.getInt("id_venta"));
              System.out.println("  ID Cliente: " + rs.getInt("id_cliente"));
              System.out.println("  ID Vendedor: " + rs.getInt("id_vendedor"));
              System.out.println("  ID Vehículo: " + rs.getInt("id_vehiculo"));
              System.out.println("  Fecha: " + rs.getTimestamp("fecha_venta"));
              System.out.println("  Precio Final: $" + rs.getBigDecimal("precio_final"));
              System.out.println("  Estado Pago: " + rs.getString("estado_pago"));
              String obs = rs.getString("observacion_pago");
              System.out.println("  Observación: " + (obs != null ? obs : "(ninguna)"));
              
              String sqlPagos = "SELECT COUNT(*) as total, COALESCE(SUM(importe_pago), 0) as total_pagado " +
                               "FROM pago WHERE id_venta = ?";
              try (var ps2 = cn.prepareStatement(sqlPagos)) {
                ps2.setInt(1, idVenta);
                try (var rs2 = ps2.executeQuery()) {
                  if (rs2.next()) {
                    System.out.println("\n  Pagos asociados: " + rs2.getInt("total"));
                    System.out.println("  Total pagado: $" + rs2.getBigDecimal("total_pagado"));
                  }
                }
              }
            } else {
              System.out.println("✗ No se encontró venta con ID " + idVenta);
            }
          }
        }
        
      } else if (subOpcion.equals("2")) {
        System.out.print("Ingrese ID de pago: ");
        int idPago = Integer.parseInt(scanner.nextLine().trim());
        
        String sql = "SELECT p.id_pago, p.id_venta, p.fecha_pago, p.metodo_pago, " +
                     "p.importe_pago, p.estado_pago, p.referencia_pago " +
                     "FROM pago p WHERE p.id_pago = ?";
        
        try (var ps = cn.prepareStatement(sql)) {
          ps.setInt(1, idPago);
          try (var rs = ps.executeQuery()) {
            if (rs.next()) {
              System.out.println("\n✓ PAGO ENCONTRADO:");
              System.out.println("  ID Pago: " + rs.getInt("id_pago"));
              System.out.println("  ID Venta: " + rs.getInt("id_venta"));
              System.out.println("  Fecha: " + rs.getTimestamp("fecha_pago"));
              System.out.println("  Método: " + rs.getString("metodo_pago"));
              System.out.println("  Importe: $" + rs.getBigDecimal("importe_pago"));
              System.out.println("  Estado: " + rs.getString("estado_pago"));
              String ref = rs.getString("referencia_pago");
              System.out.println("  Referencia: " + (ref != null ? ref : "(ninguna)"));

              int idVenta = rs.getInt("id_venta");
              String sqlVenta = "SELECT precio_final, estado_pago FROM venta WHERE id_venta = ?";
              try (var ps2 = cn.prepareStatement(sqlVenta)) {
                ps2.setInt(1, idVenta);
                try (var rs2 = ps2.executeQuery()) {
                  if (rs2.next()) {
                    System.out.println("\n  Venta asociada:");
                    System.out.println("    Precio total: $" + rs2.getBigDecimal("precio_final"));
                    System.out.println("    Estado: " + rs2.getString("estado_pago"));
                  }
                }
              }
            } else {
              System.out.println("✗ No se encontró pago con ID " + idPago);
            }
          }
        }
        
      } else {
        System.out.println("Opción no válida.");
      }
      
    } catch (NumberFormatException e) {
      System.err.println("✗ Error: Debe ingresar un número válido.");
    } catch (Exception e) {
      System.err.println("✗ Error: " + e.getMessage());
    }
  }
  
  private static void probarDAOOriginal() {
    try {
      PagoDAO dao = new PagoDAO();
      
      try (var cn = DB.get();
           var ps = cn.prepareStatement("SELECT id_venta FROM venta ORDER BY id_venta DESC LIMIT 1");
           var rs = ps.executeQuery()) {
        
        if (rs.next()) {
          int idVenta = rs.getInt("id_venta");
          System.out.println("Usando idVenta existente=" + idVenta);
          
          long nuevoPagoId = dao.registrarPago(idVenta, PagoDAO.MetodoPago.EFECTIVO, new BigDecimal("5000"));
          System.out.println("✓ Pago insertado id=" + nuevoPagoId);
          
          System.out.println("\n→ VERIFICACIÓN:");
          var ps2 = cn.prepareStatement("SELECT * FROM pago WHERE id_pago = ?");
          ps2.setLong(1, nuevoPagoId);
          var rs2 = ps2.executeQuery();
          if (rs2.next()) {
            System.out.printf("  Pago #%d: Venta #%d | %s | $%.2f%n",
                rs2.getLong("id_pago"),
                rs2.getInt("id_venta"),
                rs2.getString("metodo_pago"),
                rs2.getBigDecimal("importe_pago"));
          }
          rs2.close();
          ps2.close();
        } else {
          System.out.println("⚠ No hay ventas en la base de datos. Inserta una venta primero.");
        }
      }
    } catch (Exception e) {
      System.err.println("Error al probar DAO: " + e.getMessage());
      e.printStackTrace();
    }
  }
}
