/*
Aaleem Siddiqui
BodyMassIndex.java
This program asks the user to tenter the amount of money he or she wants to enter into the slot machine. it will randomly select a word from
a list and if none of the randomly selected words match, the program will informt eh user that he or she has won 0. if two of the
words match, the program will inform the user that he or she has won two time st he amount entered. if three of the words match,
the program will informt eh user that he or she has won three times the amount entered. 


pseudocode:
-ask user for wager
-spin
    -random int for first slot
    -random int for second slot
    -random int for third slot
-if two random ints match
   -double reward
-if all three random ints match
   -triple reward
-if none match
   -reward is set to 0
-add to total rewards




two things that i have improved in this weeks submission is being well organized and being clean,clear, and concise in output.
*/
   
import java.util.Scanner; //needed to scan user input
import java.util.Random; 
import java.io.*;

  
public class SlotMachineSimulation
{
   public static void main(String[] args)
   {
        Scanner keyboard = new Scanner(System.in); //create scanner for input data
        Random randInt = new Random();
       
           
        System.out.println("How Much Money would you like to enter into the slot machine? "); //user enters in wager amount 
        int wager = keyboard.nextInt();
       
       // random number generator for 3 slots   
        int val1 = randInt.nextInt(6) + 1;
        int val2 = randInt.nextInt(6) + 1;
        int val3 = randInt.nextInt(6) + 1;
        String valName1 = " ", valName2 = " ", valName3 = " "; //value names
        double userTotal = 0.0; //user total
        
         switch (val1)// 3 switch statements for random values
                {
                    case 1:
                        valName1 = "Cherries";
                        break;
                    case 2:
                        valName1 = "Oranges";
                        break;
                    case 3:
                        valName1 = "Plums";
                        break;
                    case 4:
                        valName1 = "Bells";
                        break;
                    case 5:
                        valName1 = "Melons";
                        break;
                    case 6:
                        valName1 = "Bars";
                        break;
                }

                switch (val2)
                {
                    case 1:
                        valName2 = "Cherries";
                        break;
                    case 2:
                        valName2 = "Oranges";
                        break;
                    case 3:
                        valName2 = "Plums";
                        break;
                    case 4:
                        valName2 = "Bells";
                        break;
                    case 5:
                        valName2 = "Melons";
                        break;
                    case 6:
                        valName2 = "Bars";
                        break;
                }

                switch (val3)
                {
                    case 1:
                        valName3 = "Cherries";
                        break;
                    case 2:
                        valName3 = "Oranges";
                        break;
                    case 3:
                        valName3 = "Plums";
                        break;
                    case 4:
                        valName3 = "Bells";
                        break;
                    case 5:
                        valName3 = "Melons";
                        break;
                    case 6:
                        valName3 = "Bars";
                        break;
                }
                
                System.out.println("\n-------------------------------");
                System.out.printf("%-12s%-10s%5s\n", valName1, valName2, valName3); //prints out random generation of values
                System.out.print("-------------------------------\n"); 
            
               //reward calculation
                if (val1 == val2 || val2 == val3 || val1 == val3)
                {
                    System.out.println("\nNumber of matches: 1"); //doubles reward
                    double doubleReward = (wager * 2);
                    double postBetSum = (userTotal + doubleReward);
                    System.out.printf("You have won: $%.2f", doubleReward);
                    System.out.printf("\nYou currently have: $%.2f", postBetSum);
                }
                else if (val1 == val2 && val2 == val3)
                {
                    System.out.println("\nNumber of matches: 3"); //triples reward
                    double tripleReward = (wager * 3);
                    double postBetSum = (userTotal + tripleReward);
                    System.out.printf("\nYou have won: $%.2f",tripleReward);
                    System.out.printf("\nYou currently have: $%.2f", postBetSum);
                }
                else
                {
                    System.out.println("\nNumber of matches: 0");//no reward
                    System.out.println("You have won: $0.00");
                    System.out.printf("You currently have: $%.2f", userTotal);
                }
        
     
        
        
           
   
    
   }
}