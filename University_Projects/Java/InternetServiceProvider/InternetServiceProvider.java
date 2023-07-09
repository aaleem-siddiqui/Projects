/*
Aaleem Siddiqui
InternetServiceProvider.java
This program calculates a customers monthly bill. It asks the user to enter the letter of the package the customer has purchased
(A, B, or C) and the number of hours that were used. It then displays the total charges. 

pseucode:
-prompt user to enter type of plan (a b or c)
-prompt user to enter number of hours used on plan
-declare variables for calculation purposes
-switch statement
   -case a: 9.95 + additional hours
            output total charges
   -case b: 13.95 + additional hours
            output total charges
   -case c: 19.95 + no additional hours
            output total charges
   -default: invalid input
            
-end program


*/

import java.io.*;
import java.util.Scanner;  // Needed for the Scanner class
import javax.swing.JOptionPane; // Needed for dialogue box

  
public class InternetServiceProvider
{
   public static void main(String[] args)throws Exception
   {
   
       Scanner keyboard = new Scanner(System.in); //scanner for user input
       String s = JOptionPane.showInputDialog("Please enter the letter of the package you have purchased (A,B, or C): "); //have user choose plan
       System.out.println("Please enter the amount of hours you have used on your plan: "); //have user enter amount of hours used on plan
       int hours = keyboard.nextInt(); //user input for hours
       
       //declared variables
       double PAadditionalHours = hours - 10; //plan a is covered under 10 hours, more hours are considered additional
       double PBadditionalHours = hours - 20; //play b is covered under 20 hours, more hours are considered additional
       double totalCharges; //calculation to be determined in switch statement
       char ch = s.charAt(0); //grabs first character from string
    
    
       
            switch(ch) //switch statement for user input of plan
            {
                  case 'a':
                  case 'A': 
                  totalCharges = (PAadditionalHours * 2) + 9.95; //add additional hours to plan charge of plan a
                  System.out.println("your total charges are:" + totalCharges); //output of total charges of plan a
                  break;
 
                  case 'b':
                  case 'B':
                  totalCharges = PBadditionalHours + 13.95; //add additional hours to plan charge of plan b
                  System.out.println("your total charges are:" + totalCharges); //output of total charges on plan b
                  break;
 
                  case 'c':
                  case 'C':
                  totalCharges = 19.95; //plan c has unlimited hours so there will be no additional
                  System.out.println("your total charges are:" + totalCharges); //output of total charges on plan c
                  break;
 
                  default: 
                  System.out.println("invalid input"); //in the event the user did not enter plan a b or c
                  break;
            }
    }
}