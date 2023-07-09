/*
Aaleem Siddiqui
IST242

Problem 2: [15 points]


*/


import java.util.Scanner;

public class GaussianSummation 
   {
      public static void main(String[] args) 
         {
         
            // first half of problem 2
            // declaring sum as 0
            int sum1 = 0;
            
            // for loop that incremently increases i and adds to the sum
            for (int i = 1; i <= 100; i++) 
               {
                  sum1 += i;
               }

            // displays final output for sum
            System.out.println("Welcome!");
            System.out.println("The Sum of 1+2+3...100 is : " + sum1);
            System.out.println();
            
////////////////////////////////////////////////////////////////////
            // second half of problem 2
            
            Scanner reader = new Scanner(System.in);
            
            // declaring a new variable for sum as 0
            int sum2 = 0;
  
            // getting user input for n
            System.out.println("Now we are going to use a value given by the user.");
            System.out.print("Please Enter a value for n: ");
            int n = Integer.parseInt(reader.nextLine());
  
            // instead of using 100, using user input in loop
            for (int j = 1; j <= n; j++) 
               {
                  sum2 += j;
               }
            
            // displaying final output of second sum w/ user input
            System.out.println("Sum of 1+2+3... " + n + " is : " + sum2);
         }
   }


