package logConverter;

import java.sql.Connection;
import java.sql.Date;
import java.sql.DriverManager;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.SQLIntegrityConstraintViolationException;
import java.sql.Time;
import java.util.ArrayList;
import java.util.GregorianCalendar;
import java.util.TimeZone;


public class DatabaseCommunication {

	private static DatabaseCommunication instance;
	private final static String connectString = "jdbc:oracle:thin:@localhost:1521:xe";
	private final static String userName = "sep";
	private final static String password = "sep";
	private static Connection conn;
	
	private DatabaseCommunication() {
		try {
			DriverManager.registerDriver(new oracle.jdbc.OracleDriver());
			conn = DriverManager.getConnection(connectString, userName, password);
			conn.setAutoCommit(false);
			
		} catch (SQLException e) {
			e.printStackTrace();
		}
	}
	
	public static DatabaseCommunication getInstance() {
		
		if (instance == null) {
			instance = new DatabaseCommunication();
		}
		return instance;
	}
	
	public void insertLog(Log log, String fileName) throws SQLException {
		PreparedStatement statement = conn.prepareStatement("insert into flight "
				+ "(ID, gps_altitude, pressure_altitude, satellite_coverage, position_longitude, position_latitude, log_time, flight_id)"
				+ " values (idFlightSequence.nextval,?,?,?,?,?,?,?)");
		statement.setDouble(1, log.getGpsAltitude());
		statement.setDouble(2, log.getPressureAltitude());
		statement.setString(3, Character.toString(log.getSateliteCoverage()));
		statement.setString(4, log.getPositionLongitude());
		statement.setString(5, log.getPositionLatitude());
		GregorianCalendar calendar = new GregorianCalendar(TimeZone.getTimeZone("UTC"));
		statement.setString(6, log.getHH()+":"+log.getMM()+":"+log.getSS());
		statement.setString(7, fileName);
		statement.executeQuery();
		statement.close();
		conn.commit();
		}
}
