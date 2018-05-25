package logConverter;

import java.util.GregorianCalendar;

public class Weather
{
   private double pressure;
   private double dewPointTemperature;
   private double surfaceTemperature;
   private String cloudCover;
   private String visibility;
   private double windDirection;
   private double windSpeed;
   private int DD;
   private int HH;
   private int MM;
   private String airport;
   
   public Weather(double pressure, double dewPointTemperature, double surfaceTemperature, String cloudCover,
         String visibility, double windDirection, double windSpeed,int dD, int hH, int mM, String airport) {
      this.pressure = pressure;
      this.dewPointTemperature = dewPointTemperature;
      this.surfaceTemperature = surfaceTemperature;
      this.cloudCover = cloudCover;
      this.visibility = visibility;
      this.windDirection = windDirection;
      this.windSpeed = windSpeed;
      DD = dD;
      HH = hH;
      MM = mM;
      this.airport = airport;
   }

   public double getPressure() {
      return pressure;
   }

   public double getDewPointTemperature() {
      return dewPointTemperature;
   }

   public double getSurfaceTemperature() {
      return surfaceTemperature;
   }

   public String getCloudCover() {
      return cloudCover;
   }
   

   public String getVisibility() {
      return visibility;
   }
   
   public double getWindDirection(){
      return windDirection;
   }
   
   public double getWindSpeed(){
      return windSpeed;
   }
   
   public int getDD(){
      return DD;
   }

   public int getHH() {
      return HH;
   }

   public int getMM() {
      return MM;
   }
   
   public String getAirport(){
      return airport;
   }

}
