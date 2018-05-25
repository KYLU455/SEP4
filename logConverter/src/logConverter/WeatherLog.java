package logConverter;

public class WeatherLog
{
   private String pressure;
   private double dewPointTemperature;
   private double temperature;
   private String cloudCover;
   private String visibility;
   private String windDirectionSpeed;
   private String DD;
   private String HH;
   private String MM;
   private String SS;
   private String airport;

   public WeatherLog(String pressure, double dewPointTemperature, double temperature, String cloudCover,
         String visibility, String windDirectionSpeed, String DD, String HH, String MM, String SS, String airport) {
      this.pressure = pressure;
      this.dewPointTemperature = dewPointTemperature;
      this.temperature = temperature;
      this.cloudCover = cloudCover;
      this.visibility = visibility;
      this.windDirectionSpeed = windDirectionSpeed;
      this.DD = DD;
      this.HH = HH;
      this.MM = MM;
      this.SS = SS;
      this.airport = airport;
   }

   public String getPressure() {
      return pressure;
   }

   public double getDewPointTemperature() {
      return dewPointTemperature;
   }

   public double temperature() {
      return temperature;
   }

   public String getCloudCover() {
      return cloudCover;
   }

   public String getVisibility() {
      return visibility;
   }

   public String getWindDirectionSpeed() {
      return windDirectionSpeed;
   }
   
   public String getDD(){
      return DD;
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
   
   public String getAirport(){
      return airport;
   }

}
