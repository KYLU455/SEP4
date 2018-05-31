package logConverter;

import java.sql.SQLException;
import java.util.ArrayList;

import Model.Flight;

public class ThermalFinder {
	
	private ArrayList<Flight> flights;
	
	public ThermalFinder(ArrayList<Flight> flights) {
		this.flights = flights;
	}

	public static void main(String []args) throws SQLException {
		ThermalFinder thermalFinder = new ThermalFinder(DatabaseCommunication.getInstance().getFlights());
	}
}
