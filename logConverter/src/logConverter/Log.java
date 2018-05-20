package logConverter;

import java.util.GregorianCalendar;

public class Log {

	private double gpsAltitude;
	private double pressureAltitude;
	private char sateliteCoverage;
	private String positionLongitude;
	private String positionLatitude;
	private String HH;
	private String MM;
	private String SS;

	public Log(double gpsAltitude, double pressureAltitude, char sateliteCoverage, String positionLongitude,
			String positionLatitude, String hH, String mM, String sS) {
		this.gpsAltitude = gpsAltitude;
		this.pressureAltitude = pressureAltitude;
		this.sateliteCoverage = sateliteCoverage;
		this.positionLongitude = positionLongitude;
		this.positionLatitude = positionLatitude;
		HH = hH;
		MM = mM;
		SS = sS;
	}

	public double getGpsAltitude() {
		return gpsAltitude;
	}

	public double getPressureAltitude() {
		return pressureAltitude;
	}

	public char getSateliteCoverage() {
		return sateliteCoverage;
	}

	public String getPositionLongitude() {
		return positionLongitude;
	}

	public String getPositionLatitude() {
		return positionLatitude;
	}

	public String getHH() {
		return HH;
	}

	public String getMM() {
		return MM;
	}

	public String getSS() {
		return SS;
	}

}
