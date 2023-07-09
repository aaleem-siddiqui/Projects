/*
Aaleem Siddiqui
IST242

Problem 4: [20 points] 

Write a program that reads an integer and displays, using asterisks, a filled diamond of the given side length. For example, if the side length is 4, the program should display

   *

  ***

 *****

******* 

 *****

  ***

   *

Provide your solution in a class named as PrintDiamond.
*/


import java.util.*;

   public class PrintDiamond
      {
         public static void main(String args[])
            {
               // declaring for loop variables
               int i;
               int y;
               int x;
               
               // welcome message / getting side length from user
               Scanner in = new Scanner(System.in);
               System.out.println("Welcome!");
               System.out.println("I am going to create a diamond for you.");       
               System.out.print("Please enter the side length: ");
               int number = in.nextInt();
               System.out.println("Here we go!");
               System.out.println();
               
               // for loop for first half of diamond
               for(i = 0; i < number; i++)
                  {
                     for(y = number - i - 1; y >= 0; y--)   
                        { 
                           System.out.print(" ");
                        }
                     for(x = i * 2 + 1; x > 0; x--)
                        {   
                           System.out.print("*");
                        }
                     System.out.println("");
                  }
         
               // for loop for second half of diamond
               for(i = number - 2; i >= 0; i--)
                  {
                     for(y = 0; y <= number - 1 - i; y++)   
                        {
                           System.out.print(" ");
                        }
                     for(x = i * 2 + 1; x > 0; x--)
                        {   
                           System.out.print("*");
                        }
                     System.out.println("");
                  }
            }
      }