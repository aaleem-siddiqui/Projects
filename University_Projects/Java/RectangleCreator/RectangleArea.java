/**
Aaleem Siddiqui
RectangleArea.java
The program will ask the user to enter the width and length of a rectangle, and then display the ractangles area. 


pseudocode:
-Get the rectangles length from the user
-Get the rectangles width from the user
-calculate the area of the rectangle from entered length and width
-display the area of the rectangle.

*/

// Insert any necessary import statements here.
import java.util.Scanner;

public class RectangleArea
{
   public static void main(String[] args)
   {
      Scanner keyboard = new Scanner(System.in); //create scanner for input data
      double getLength,    // The rectangle's length
             getWidth,     // The rectangle's width
             getArea;      // The rectangle's area
   
   
   
      // Get the rectangle's length from the user.
      System.out.println("Enter the length of the rectangle: ");
      getLength = keyboard.nextDouble(); 
      
   
      // Get the rectangle's width from the user.
      System.out.println("Enter the width of the rectangle: ");
      getWidth = keyboard.nextDouble(); 
      

      // Get the rectangle's area.
      getArea = getLength * getWidth;

      // Display the rectangle data.
      System.out.println("The area if the rectangle is " + getArea);
      
         
        
       
   }
}