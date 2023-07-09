/*
Aaleem Siddiqui
IST242

Problem 3: [25 points]

Write a recursive method that takes a positive integer n and find the sum of all the integers from 0 to n
*/

import java.util.Scanner;


public class recursiveAddition
   {
      public static void main(String[] args) // main function
         {
            Scanner keyboard = new Scanner(System.in);
         
       
            System.out.print("Give me a number: "); // user input for 'n' 
            int n = keyboard.nextInt();
            System.out.println(); // placeholder
            
            int sum = addNumbers(n); // recursive addition function
            System.out.println("The sum of 0+...+" + n + " is: " + sum); // final output
         }


      // recursive addition happens here
      public static int addNumbers(int number) 
         {
            if (number != 0)
                  return number + addNumbers(number - 1);
            else
                  return number;
    }
}