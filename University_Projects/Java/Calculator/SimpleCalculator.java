/*
Aaleem Siddiqui
SimpleCalculator.java
Prompt user for two doubles (num1,  num2) and a char(operation), and perform operation to display result.


pseudocode:
-Prompt user to select operation (1 for addition, 2 for subtraction, 3 for multiplication, and 4 for division)
-Prompt to ask user for first number
-Prompt to ask user for second number
-switch statement follows path for operation and calculates result
-Display final result


*/
   
import java.util.Scanner;

  
public class SimpleCalculator
{
   public static void main(String[] args)
   {
        Scanner keyboard = new Scanner(System.in); //create scanner for input data
        System.out.println("operations// "); 
        System.out.println("1. addition");
        System.out.println("2. subtraction ");
        System.out.println("3. multiplication ");
        System.out.println("4. division");
        System.out.println("enter the number next to your choice of operation: ");//prompt user for operation
        int operation = keyboard.nextInt(); //user enters operation
           
        System.out.println("enter your first number:");
        int num1 = keyboard.nextInt(); //user enters first number for operation
           
        System.out.println("enter your second number: ");
        int num2 = keyboard.nextInt(); //user enters second number for operation
        
        double result = 0; //result will just store the result of the operation
          
   switch ( operation ) //switch statement to perform operation decided by user
   {
      case 1: //Addition
               result = num1 + num2;
               break;
      case 2: //Subtraction 
               result = num1 - num2;              
               break;
      case 3: //multiplication 
               result = num1 * num2;
               break;
      case 4: //division
               if(num2 == 0)//nothing is divisible by zero...
               {
                  System.out.println("division is not possible");
                  break;
               }
               else
               result = num1 / num2; //any number other than zero for num2 will be used
               
      default:
               System.out.println("Invalid Choice." ); //in the event the user does not choose 1 2 3 or 4 for operation
   }
   
   System.out.println("your final result is = " + result); //program displays final result
    
   }
}