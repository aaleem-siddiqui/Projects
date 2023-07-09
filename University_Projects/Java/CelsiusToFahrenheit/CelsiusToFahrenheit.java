/**
Aaleem Siddiqui
CelsiusToFahrenheit.java
This program displays a table of the celsius temperatures 0 through 20 and their fahrenheit equivalents. 


pseudocode:
- declare variables ( celsius and fahrenheit)
- while loop that loops until the increment hits 20 (increment is celsius temp)
   - have formula calculate fahrenheit from increment
   - output celsius and fahrenheit equivalent 
   - increment++;
- end

*/

public class CelsiusToFahrenheit
{
   public static void main(String [] args)
   {
      // declare variables
      double Celsius = 0;
      double Fahrenheit;

      //while loop that continues until the increment hits 20
      while (Celsius <= 20) //increment is also celsius
      {
         Fahrenheit = (((Celsius * 9) / 5) + 32);//f to c formula per increment
         System.out.println("Celsius = " + Celsius + " | Fahrenheit = " + Fahrenheit); //outputs each line of the table
         Celsius++; //increases increment or celsius by one each loop
      }

      System.out.println("That's all!");
   }
}