/*
Aaleem Siddiqui
RestaurantBill.java
This program computes the tax and tip on a restaurantbill. The program asks the user to enter the charge for the
meal, displays the meal charge, tax amount, tip amount, and total bill on the screen. 

pseudocode:
have user input charge for meal;
calculate tax;
   6.75 percent of meal charge;
   store tax in int variable;
calculate tip;
   20 percent of meal charge;
   store tip in int variable;
output meal charge;
output tax;
output tip;
output total bill;

*/
   
import java.util.Scanner;
  
public class RestaurantBill
{
   public static void main(String[] args)
   {

  
   //initialize variables
 
   Scanner reader = new Scanner(System.in);
   double tax;
   double tip;
   double totalAmount;
   String inputString;
   
   
   // Get the charge for the meal
   
         
      System.out.println("what was the charge of your meal? ");
      Scanner in = new Scanner(System.in);
      double mealCharge = in.nextInt();
   
   //calculate tax
   tax = mealCharge * .675;
   
   //calculate tip
   tip = mealCharge *.20;
  
   //calculate total amount
   totalAmount = mealCharge + tax + tip;
   
     // Display the results.
      System.out.println("meal charge $" + mealCharge);
      System.out.println("tax $" + tax);
      System.out.println("tip $" + tip); 
      System.out.println("total amount $" + totalAmount);      
      
   }
}
