/*
Aaleem Siddiqui
StringManipulator.java
This program asks the user to enter the name of his or her favorite city. Using a string variable to store the 
input, the program should display the number of characters in the city name, the name of the city in all uppercase
letters, the name of the city in all lowercase letters, and the first character in the name of the city. 

pseudocode:
have user input favorite city;
store user input as string variable;
manipulate string to store all characters in uppercase;
manipulate string to store all characters in lowercase;
retrieve first character from string and store in char;
count number of characters in string and store in int;
output number of characters in the city name;
output the name of the city in all uppercase letters;
output the name of the city in all lowercase letters;
output the first character in the name of the city;

*/
import java.util.Scanner;  // Needed for the Scanner class
import javax.swing.JOptionPane; // Needed for dialogue box

public class StringManipulator
{
   public static void main(String[] args)
   {
        // Create a Scanner object to read input.
      Scanner keyboard = new Scanner(System.in);


      // Get the user's favorite city.
      String name = JOptionPane.showInputDialog("What is the name of your favorite city? ");

      //initialize string manipulations
      String upper = name.toUpperCase();
      String lower = name.toLowerCase();
      char letter = name.charAt(0);
      int stringSize = name.length();

      //output number of characters in city name
      System.out.print("The number of characters in your city name is: ");
      System.out.println(stringSize);
      
      //output city name in uppercase letters
      System.out.print("Your city in all uppercase letters is: ");
      System.out.println(upper);
      
      //output city name in lowercase letters
      System.out.print("Your city in all lowercase letters is: ");
      System.out.println(lower);
      
      //output first character in city name
      System.out.print("The First character in the name of your city is: ");
      System.out.println(letter);
      
      
   }
}
