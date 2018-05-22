package logConverter;

import java.sql.Statement;
import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.PreparedStatement;
import java.sql.SQLException;
import java.sql.SQLIntegrityConstraintViolationException;
import java.sql.Time;
import java.sql.Timestamp;
import java.util.Calendar;
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
	
	public void insertLog(Log log, String fileName, int day, int month, int year) throws SQLException {
		Statement statement = conn.createStatement();
		statement.executeQuery("insert into flight "
				+ "(ID, gps_altitude, pressure_altitude, satellite_coverage, position_longitude, position_latitude, log_time, flight_id)"
				+ " values (idFlightSequence.nextval"
				+ "," + log.getGpsAltitude()
				+ "," + log.getPressureAltitude()
				+ ",'" + log.getSateliteCoverage() + "'"
				+ ",'" + log.getPositionLongitude() + "'"
				+ ",'" + log.getPositionLatitude() + "'"
				+ ", timestamp '" + (year + 2000) + "-" + month + "-" + day + " " + log.getHH() + ":" + log.getMM() + ":" + log.getSS() + "UTC'"
				+ ",'" + fileName + "'"
				+ ")");
		statement.close();
		conn.commit();
		}
}
