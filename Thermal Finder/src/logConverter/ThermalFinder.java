package logConverter;

import java.sql.SQLException;
import java.util.ArrayList;

import Model.Flight;
import Model.Log;
import Model.Thermal;

public class ThermalFinder {
	
	private ArrayList<Flight> flights;
	
	public ThermalFinder(ArrayList<Flight> flights) {
		this.flights = flights;
		findThermal(this.flights.get(0));
//		for (Flight flight : flights) {
//			findThermal(flight);
//		}
	}

	public ArrayList<Thermal> findThermal(Flight flight) {
		ArrayList<Thermal> thermals = new ArrayList<>();
		
		ArrayList<Log> increment = new ArrayList<>();
		double lastAlt = flight.getLogs().get(0).getAltitude();
		for(int a = 1 ; a < flight.getLogs().size(); a++) {
			if(lastAlt <= flight.getLogs().get(a).getAltitude() && lastAlt > 500) {
				increment.add(flight.getLogs().get(a));
			}
			else {
				if (increment.size() > 10 && increment.get(increment.size() - 1).getAltitude() - increment.get(0).getAltitude() > 50) {
					System.out.println("found one " + flight.getName());
//					for (Log log : increment) {
//						System.out.println(log.getAltitude());
//					}
					thermals.add(new Thermal(increment.get(0).getDate(), increment));
				}
				increment = new ArrayList<>();
			}
			lastAlt = flight.getLogs().get(a).getAltitude();
		}
		
		return thermals;
	}
	
	public static void main(String []args) throws SQLException {
		ThermalFinder thermalFinder = new ThermalFinder(DatabaseCommunication.getInstance().getFlights());
	}
}
