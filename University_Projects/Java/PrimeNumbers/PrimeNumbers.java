/*
Aaleem Siddiqui
IST242

Problem 3: [10 points]

Prime numbers. Write a program that prompts the user for an integer and then prints out all prime numbers up to that integer. For example, when the user enters 20, the program should print

2

3 

5

7

11

13

17

19

Provide your solution in a class named as PrimeNumbers.
*/

import java.util.Scanner;

public class PrimeNumbers
   {
	   public static void main(String[] args)
	      {
		      int x;
            int y;
		      Scanner s = new Scanner(System.in);
            
            // welcome message and getting user input
            System.out.println("Welcome!");
            System.out.println("I am going to provide all of the prime numbers up to a number that you provide.");
		      System.out.print("Please enter a number: ");
            x = s.nextInt();
            System.out.println();
            System.out.println("Here we go!");
            System.out.println();
		      
            
            // calculating prime numbers
		      for(int i = 2; i < x; i++)
		         {
			         y = 0;
			         for(int j = 2; j < i; j++)
			            {
				            if(i % j == 0)
				            y = 1;
			            }
			         if( y == 0)
                     {
				         System.out.println(i);
                     }
		         }
	      }
   }