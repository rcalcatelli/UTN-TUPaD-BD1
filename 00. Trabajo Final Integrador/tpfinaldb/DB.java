package tpfinaldb;
import java.sql.Connection;
import java.sql.DriverManager;

public final class DB {
  private static final String URL  =
      "jdbc:mysql://localhost:3306/concesionaria"
    + "?useSSL=false&useUnicode=true&characterEncoding=UTF-8"
    + "&serverTimezone=America/Argentina/Cordoba"
    + "&connectTimeout=5000&socketTimeout=10000";

  private static final String USER = "vendedor_app";
  private static final String PASS = "VendApp2025!Secure";

  private DB() {}

  public static Connection get() throws Exception {
    Connection conn = DriverManager.getConnection(URL, USER, PASS);
    conn.setNetworkTimeout(java.util.concurrent.Executors.newSingleThreadExecutor(), 10000);
    return conn;
  }
}