package Model;

import java.util.GregorianCalendar;

public class Log {

	private double latitude;
	private double longitude;
	private double altitude;

	public Log(String latitude, String longitude, double altitude) {
		int m = 1;
		if(latitude.charAt(latitude.length() - 1) == 'W') {
			m = -1;
		}
		this.latitude = Integer.parseInt(latitude.substring(0, latitude.length() - 1)) * m;
		m = 1;
		if(longitude.charAt(longitude.length() - 1) == 'S') {
			m = -1;
		}
		this.longitude = Integer.parseInt(longitude.substring(0, longitude.length() - 1)) * m;
		this.altitude = altitude;
	}

	public double getLatitude() {
		return latitude;
	}

	public double getLongitude() {
		return longitude;
	}

	public double getAltitude() {
		return altitude;
	}
}
