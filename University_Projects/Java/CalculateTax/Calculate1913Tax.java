/*
Aaleem Siddiqui
IST242

Problem 1: [15 points]

The original U.S. income tax of 1913 was quite simple. The tax was

* 1 percent on the first $50,000

* 2 percent on the amount over $50,000 up to $75,000

* 3 percent on the amount over $75,000 up to $100,000

* 4 percent on the amount over $100,000 up to $250,000

* 5 percent on the amount over $250,000 up to $500,000

* 6 percent on the amount over $500,000

There was no separate schedule for single or married taxpayers. Write a program that computes the income tax according to this schedule. 

Provide your solution in a class named as Calculate1913Tax.

*/


import java.util.Scanner;

public class Calculate1913Tax
   {
      public static void main(String[] args)
         {
            Scanner in = new Scanner(System.in);
            System.out.println("Welcome!");
            System.out.println("Enter your income: "); // getting user input
            double income = in.nextDouble(); // storing user input
            TaxReturn aTaxReturn = new TaxReturn(income); // using taxreturn class to calculate tax
            System.out.println("Your Tax is: " + aTaxReturn.getTax()); // outputting tax
         }
   }



// calculating tax return class

class TaxReturn
   {
      private double income;

      public TaxReturn(double i)
         {
            income = i;
         }
      public double getTax()
         {
            // if else statement to filter user input to tax percentage
            double tax = 0;
            if(income <= 50000)
               return income * .01;
            if(income <= 75000)
               return 50000 * .01 + (income - 50000) * .02;
            if(income <= 100000)
               return 50000 * .01 + 25000 * .02 + (income - 75000) * .03;
            if(income <= 250000)
               return 50000 * .01 + 25000 * .02 + 25000 * .03 + (income - 100000) * .04;   
            if(income <= 500000)
               return 50000 * .01 + 25000 * .02 + 25000 * .03 + 150000 * .04 + (income - 250000) * .05;
            return 50000 * .01 + 25000 * .02 + 25000 * .03 + 150000 * .04 + 250000 * .05 + (income - 500000) * .06;   
         }
   }   