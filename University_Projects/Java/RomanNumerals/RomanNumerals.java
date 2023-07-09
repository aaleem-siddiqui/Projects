/*
Aaleem Siddiqui
RomanNumerals.java
4.1


*/
   
import java.util.Scanner;

  
public class RomanNumerals
{
   public static void main(String[] args)
   {
        Scanner keyboard = new Scanner(System.in); //create scanner for input data
        System.out.println("Enter a number in the range of 1 - 10: ");//prompt user for operation
        int operation = keyboard.nextInt(); //user enters operation
        
        
        
          
   switch ( operation ) 
   {
      case 1: 
               System.out.println("I" );
               break;
      case 2: 
               System.out.println("II" );
               break;
      case 3: 
               System.out.println("III" );
               break;
      case 4: 
               System.out.println("IV" );
               break;
      case 5: 
               System.out.println("V" );
               break;
      case 6: 
               System.out.println("VI" );
               break;
      case 7: 
               System.out.println("VII" );
               break;
      case 8: 
               System.out.println("VIII" );
               break;
      case 9: 
               System.out.println("IX" );
               break;
      case 10: 
               System.out.println("X" );
               break;
               
               
      default:
               System.out.println("Invalid Choice." ); 
   }
   
   
    
   }
}