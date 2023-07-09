/*
Aaleem Siddiqui
RockPaperScissors.java 
This program engages the user in a game of rock paper scissors. the program chooses a variable representing rock paper or scissors
before the user enters their choice. when the user enters their choice, the winning results are displayed. 

pseudocode:
- method for rock
- method for scissors
- method for paper
- console choses rand int between 1-3
- user enters int symbolizing r s or p
- switch statement depending apon user input
- end program



*/
   
import java.util.Scanner; 
import java.util.Random; 

public class RockPaperScissors

{ 
  
public static void Rock(int consoleInput) 
      { 
         if (consoleInput == 1)
            {
               System.out.println("You and I have both chose Rock!");
               System.out.println("Lets play again!");  
            }
         else if (consoleInput == 2)
            {
               System.out.println("I chose Paper! you lose!"); 
            }   
        else if (consoleInput == 3)
           {
               System.out.println("I chose Scissors! you win!"); 
           } 
            
            
      } 
public static void Paper(int consoleInput) 
      { 
       if (consoleInput == 2)
            {
               System.out.println("You and I have both chose Rock!");
               System.out.println("Lets play again!");  
            }
         else if (consoleInput == 1)
            {
               System.out.println("I chose Rock! you win!"); 
            }   
        else if (consoleInput == 3)
           {
               System.out.println("I chose Scissors! you lose!"); 
           }    
      } 
public static void Scissors(int consoleInput) 
      { 
         if (consoleInput == 3)
            {
               System.out.println("You and I have both chose Scissors!");
               System.out.println("Lets play again!");  
            }
         else if (consoleInput == 1)
            {
               System.out.println("I chose Rock! you lose!"); 
            }   
        else if (consoleInput == 2)
           {
               System.out.println("I chose Paper! you win!"); 
           } 
      } 
      
      
////////////////////////////////////////////////////////////////////////////////////////////////


   public static void exitProgram() //exit program method
      { 
         System.out.println("Thank you."); 
         System.out.println(0); 
      } 
   public static void options() //shows options for conversion/ user input
      { 
         System.out.println(" Enter 1 for Rock "); 
         System.out.println(" Enter 2 for Paper "); 
         System.out.println(" Enter 3 for Scissors "); 
         System.out.println(" Enter 4 to exit the program "); 
         System.out.println(" "); 
      } 


///////////////////////////////////////////////////////////////////////////////////////////////////
   public static void main (String [] args) 
      { 

         
         int userInput; 
         Scanner keyboard = new Scanner (System.in); //keyboard 
         Random randInt = new Random();
         int consoleInput = randInt.nextInt(3) + 1;

        
         options(); //asks for rock paper or scissors
         userInput = keyboard.nextInt(); //stores users weapon
        
         
         switch(userInput) //switch statement, does conversion apon user input
            { 
               case 1: Rock(consoleInput); 
               break; 
               case 2: Paper(consoleInput); 
               break; 
               case 3: Scissors(consoleInput); 
               break; 
               case 4: 
               exitProgram(); 
            } 
      } 
} 
