/*
Aaleem Siddiqui
lotteryApplication.java
This program simulates a lottery. It asks the user to enter five numbers. This program displays the number of digits that match the
randomely generated lottery numbers. if all of the digits match, it displays a message proclaiming the user a grand prize winner. 

pseucode:
-store 5 random lottery numbers in array
-ask user to enter in 5 numbers and fill array2
-compare array to array2 and everyloop counts as match
-if all 5 match, grand prize winner
-else, display number of matches

*/

import java.util.Random;
import java.util.Scanner;

class Lottery 
{

	private int lotteryNumbers[];

	public Lottery() 
      {
		   Random rand = new Random(System.currentTimeMillis());
	   	lotteryNumbers = new int[5]; //create array w 5 placeholders
		   
         for (int i = 0; i < lotteryNumbers.length; i++)
            {
			      lotteryNumbers[i] = Math.abs(rand.nextInt()) % 10; //loop that fill array with 5 random integers
		      }
	   }

	
	public int compareNumbers(int[] usersNumbers) //program that compares arrays 
      {
		   int match = 0;
		   if (usersNumbers.length == lotteryNumbers.length) 
            {
			      for (int i = 0; i < lotteryNumbers.length; i++) 
                  {
				         if (usersNumbers[i] == lotteryNumbers[i]) //comparison
                        {
					            match++; //every number that matches is +1
				            }
			         }
		      }
		   return match;
	   }

	public int[] getLotteryNumbers()
      {
		   return lotteryNumbers;
	   }
}


///////////////////////////MAIN FUNCTION
public class lotteryApplication 
   {
	   public static void main(String[] args)
         {
		      Lottery lottery = new Lottery();
		      int lotteryNumbersCount = lottery.getLotteryNumbers().length;

		      System.out.println("Lottery Application\n");
		      System.out.println("There are " + lotteryNumbersCount
				+ " secret numbers in range of 0 through 9. "
				+ "Try to guess them!!!\n");

		      Scanner kb = new Scanner(System.in);
		      int numbers[] = new int[lotteryNumbersCount]; //to list numbs

		      for (int i = 0; i < numbers.length; i++)//actual user input of 5 numbers 
               {
			         System.out.print(String.format("Enter Number %d: ", i + 1));
			         numbers[i] = kb.nextInt();
		         }

		int match = lottery.compareNumbers(numbers);
		
		System.out.println("You entered: " + (numbers[0]) + (numbers[1]) + (numbers[2]) + (numbers[3]) + (numbers[4]) ); //display user input
		
		if (match == lotteryNumbersCount) //if all 5 match 
         {
            System.out.println("\nYOU ARE A GRAND PRIZE WINNER!");
         } 
      else //if <5 match
         {
			   System.out.println("\nUh-oh! You hit " + match + " number(s).");
		   }

	}
}
