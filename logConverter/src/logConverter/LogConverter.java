package logConverter;

import java.io.BufferedReader;
import java.io.File;
import java.io.FileNotFoundException;
import java.io.FileReader;
import java.io.IOException;
import java.sql.SQLException;
import java.util.GregorianCalendar;

public class LogConverter {

   private File[] files;
   private DatabaseCommunication db;
   
   public LogConverter() throws IOException {
      File forder = new File("logs");
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
         if(line.charAt(0) == 'B') {
            Log log = new Log(
                  Double.parseDouble(line.substring(30, 35)),
                  Double.parseDouble(line.substring(25, 30)),
                  line.charAt(24),
                  line.substring(15, 24),
                  line.substring(7, 15),
                  line.substring(1, 3),
                  line.substring(3, 5),
                  line.substring(5, 7));
            try {
               db.insertLog(log, file.getName().substring(0, file.getName().length() - 4));
            } catch (SQLException e) {
               System.out.println(line);
               e.printStackTrace();
            }
         }
      }
   }
   

   
   public static void main(String[] args) throws IOException {
      LogConverter converter = new LogConverter();
   }
}
