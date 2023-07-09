/**
Aaleem Siddiqui
PaintJobEstimator.java
The program will ask the user to enter the width and length of a rectangle, and then display the ractangles area. 


pseudocode:


*/

// Insert any necessary import statements here.
import java.util.Scanner;


public class PaintJobEstimator
{
   public static void main(String[] args)
   {
      Scanner keyboard = new Scanner(System.in); //create scanner for input data
      
      System.out.println("Enter the number of rooms you would like painted: ");
      int numRooms = keyboard.nextInt(); 
      
      System.out.println("Enter the square feet of wall space in each room: ");
      int squareFeet = keyboard.nextInt();
      
      System.out.println("Enter the price of the paint per gallon: ");
      double paintPrice = keyboard.nextDouble();
      
      //////////////////////////////////////////////////////////////////////////
      
      int totalSF = numRooms * squareFeet;
      int estNumOfGallons = totalSF / 115;
      int numOfGallons = estNumOfGallons + 1;
      int hoursOfLabor = numOfGallons * 8;
      double costOfPaint = paintPrice * numOfGallons;
      int costOfLabor = hoursOfLabor * 18;
      double totalCost = costOfPaint + costOfLabor; 
      
      //Double one  = new Double(numOfGallons);
      //int fuck = one.intValue();
  
      System.out.println("The number of gallons of paint required are: " + numOfGallons);
      System.out.println("The hours of labor required are: " + hoursOfLabor);
      System.out.println("The cost of the paint is: " + costOfPaint);
      System.out.println("The labor charges are: " + costOfLabor);
      System.out.println("The total cost of the paint job is: " + totalCost);
   
   
             
       
   }
}