package tpfinaldb;

import java.math.BigDecimal;
import java.sql.*;
import java.util.EnumSet;

public class PagoDAO {
  public enum MetodoPago { EFECTIVO, TRANSFERENCIA, TARJETA, CHEQUE }

  public long registrarPago(int idVenta, MetodoPago metodo, BigDecimal importe) throws Exception {
    if (idVenta <= 0) throw new IllegalArgumentException("idVenta inválido");
    if (importe == null || importe.signum() <= 0) throw new IllegalArgumentException("importe debe ser > 0");
    if (!EnumSet.allOf(MetodoPago.class).contains(metodo)) throw new IllegalArgumentException("método no permitido");

    final String sql = "INSERT INTO pago (id_venta, metodo_pago, importe_pago) VALUES (?, ?, ?)";

    try (Connection cn = DB.get()) {
      cn.setAutoCommit(false);
      try (PreparedStatement ps = cn.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {
        ps.setInt(1, idVenta);
        ps.setString(2, metodo.name());
        ps.setBigDecimal(3, importe);

        int rows = ps.executeUpdate();
        if (rows != 1) throw new SQLException("No se insertó el pago");

        long idPago = -1;
        try (ResultSet rs = ps.getGeneratedKeys()) {
          if (rs.next()) idPago = rs.getLong(1);
        }

        cn.commit();
        return idPago;

      } catch (SQLIntegrityConstraintViolationException e) {
        cn.rollback();
        throw new SQLException("Violación de integridad (FK/UNIQUE/CHECK). Revise id_venta válido, importe > 0 y método.", e);
      } catch (SQLException e) {
        cn.rollback();
        throw e;
      }
    }
  }

  public void listarVentasResumen(int limit) throws Exception {
    final String sql =
        "SELECT id_venta, fecha_venta, precio_final, total_pagado, saldo_pendiente "
      + "FROM vista_ventas_resumen ORDER BY fecha_venta DESC LIMIT ?";

    try (Connection cn = DB.get();
         PreparedStatement ps = cn.prepareStatement(sql)) {
      ps.setInt(1, Math.max(1, limit));
      try (ResultSet rs = ps.executeQuery()) {
        int count = 0;
        while (rs.next()) {
          System.out.printf("#%d | %s | $%s | pagado $%s | saldo $%s%n",
              rs.getInt("id_venta"),
              rs.getTimestamp("fecha_venta"),
              rs.getBigDecimal("precio_final"),
              rs.getBigDecimal("total_pagado"),
              rs.getBigDecimal("saldo_pendiente"));
          count++;
        }
        if (count == 0) System.out.println("(sin filas)");
      }
    }
  }
}
