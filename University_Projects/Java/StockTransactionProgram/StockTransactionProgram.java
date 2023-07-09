/*
Aaleem Siddiqui
StockTransactionProgram.java
This program calculates the money paid for the stock, the amount paid to the broker ( 2% commission ), the amount stock is sold for,
the amount of ommission paid when stock is sold, and the amount of profit that is made after selling the stock and paying the two 
commissions to the broker.

pseudocode:
have user input price of stock per share;
have user input number of shares purchased;
calculate commission for broker;
have user input new price of stock per share;
have user input number of shares sold;
calculate commission for broker;
display amount of money paid for stock;
display amount of commission paid to broker when stock is purchased;
display amount of money stock is sold for;
display amount of commission paid to broker when stick is sold;
display amount of profit that is made after selling stock and paying both commissions;

*/
   
import java.util.Scanner;
import java.util.*;
  
public class StockTransactionProgram
{
   public static void main(String[] args)
   {

  
   //initialize variables
 
     Scanner dd = new Scanner(System.in);
   
  
   
   System.out.println("Enter the price of stock per share when purchasing.");
   int initialPrice = dd.nextInt();
   System.out.println("Enter the number of shares purchased.");
   int initialShares = dd.nextInt();
   
   double total1 = initialPrice * initialShares;
   double initialCommission = total1 * .02; 
   
   System.out.println("Enter the price of stock per share when selling.");
   int currentPrice = dd.nextInt();
   System.out.println("Enter the number of shares sold.");
   int currentShares = dd.nextInt();
   
   double total2 = currentPrice * currentShares;
   double currentCommission = total2 * .02; 
   
   double profit = (total2 - currentCommission) - (total1 - initialCommission);
   
   
     // Display the results.
      System.out.println("The amount of money paid for stock:" + total1 );
      System.out.println("The amount of commission paid to broker when stock is purchased:" + initialCommission);
      System.out.println("The amount if money that the stock was sold for:" + total2); 
      System.out.println("The amount of commission paid to broker when stock is sold:" + currentCommission); 
      System.out.println("The Final profit made after selling stock and paying broker:" + profit);     
      
   }
}