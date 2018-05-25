package logConverter;

import java.io.BufferedReader;
import java.io.File;
import java.io.FileNotFoundException;
import java.io.FileReader;
import java.io.IOException;
import java.nio.file.FileSystems;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.StandardCopyOption;
import java.sql.SQLException;
import java.util.GregorianCalendar;

import oracle.net.aso.b;
   
public class WeatherConverter {

      private File[] files;
      private DatabaseCommunication db;
      private int day;
      
      public WeatherConverter() throws IOException {
         File forder = new File("weather_logs");
         files = forder.listFiles();
         db = DatabaseCommunication.getInstance();
         for (int a = 0; a < files.length; a++) {
            System.out.println(files[a].getName());
            convert(files[a]);
         }
      }
      
      public void convert(File file) throws IOException {
         FileReader fileReader = new FileReader(file);
         BufferedReader bufferedReader = new BufferedReader(fileReader);
         String line;
         while((line = bufferedReader.readLine()) != null) {
            if(line.charAt(0) == 'M'){
               Weather weather = new Weather(
                     Double.parseDouble(line.substring(55, 59)),
                     Double.parseDouble(line.substring(61, 63)),
                     Double.parseDouble(line.substring(58, 60)),
                     line.substring(40, 47),
                     line.substring(32,39),
                     Double.parseDouble(line.substring(27, 29)),
                     Double.parseDouble(line.substring(24, 27)),
                     Integer.parseInt(line.substring(11, 13)),
                     Integer.parseInt(line.substring(13, 15)),
                     Integer.parseInt(line.substring(15, 17)),
                     line.substring(6, 10));
              
            }
               else if(line.length()>=64){
                  Weather weather = new Weather(
                  Double.parseDouble(line.substring(55, 59)),
                  Double.parseDouble(line.substring(61, 63)),
                  Double.parseDouble(line.substring(58, 60)),
                  line.substring(40, 47),
                  line.substring(32,39),
                  Double.parseDouble(line.substring(27, 29)),
                  Double.parseDouble(line.substring(24, 27)),
                  Integer.parseInt(line.substring(11, 13)),
                  Integer.parseInt(line.substring(13, 15)),
                  Integer.parseInt(line.substring(15, 17)),
                  line.substring(6, 10));
            
                  try {
                     db.insertWeather(weather, file.getName().substring(0, file.getName().length() - 4), day);
                  } catch (SQLException e) {
                     System.out.println(line);
                     e.printStackTrace();
                  }
               }
            }
         }

         
         public static void main(String[] args) throws IOException {
            WeatherConverter converter = new WeatherConverter();
         }
      }