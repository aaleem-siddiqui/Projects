/*
Aaleem Siddiqui
ConversionProgram.java
This is a program that asks the user to enter a distance in meters. the program then asks the user to enter a measurement to convert
to. the program then converts the distance and displays the outcome. 


pseudocode:
- m to km method
- m to inches method
- m to feet method
- other methods
- ask for user input for distance
- ask for user input for conversion type
- switch statement based on conversion type
- display converted value


*/
   
import java.util.Scanner; 

public class ConversionProgram 

{ 
   public static void showKilometers(double meters) //m to km conversion
      { 
         double kilometers = meters * 0.001; 
         System.out.println(meters +" meters is " + kilometers + " kilometers."); 
      } 

   public static void showInches(double meters) //m to inches conversion
      { 
         double inches = meters * 39.37; 
         System.out.println(meters +" meters is " + inches + " inches."); 
      } 

   public static void showFeet(double meters) //m to feet conversion
      { 
         double feet = meters * 3.281; 
         System.out.println(meters +" meters is " + feet + " feet."); 
      } 

   public static void exitProgram() //exit program method
      { 
         System.out.println("Thank you."); 
         System.out.println(0); 
      } 
   public static void options() //shows options for conversion/ user input
      { 
         System.out.println(" 1. Convert to kilometers "); 
         System.out.println(" 2. Convert to inches "); 
         System.out.println(" 3. Convert to feet "); 
         System.out.println(" 4. Quit the program "); 
         System.out.println(" "); 
      } 

   public static void main (String [] args) 
      { 

         double meters; //declare variables
         int userInput; 
         Scanner keyboard = new Scanner (System.in); //keyboard 

         System.out.println("Enter a distance in meters: "); // asks for user input for distance
         meters = keyboard.nextDouble(); //stores user input
         options(); //asks for user input for conversion type
         userInput = keyboard.nextInt(); //stores conversion type
         
         switch(userInput) //switch statement, does conversion apon user input
            { 
               case 1: showKilometers(meters); 
               break; 
               case 2:showInches(meters); 
               break; 
               case 3:showFeet(meters); 
               break; 
               case 4: 
               exitProgram(); 
            } 
      } 
} 
