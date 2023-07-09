/*
Aaleem Siddiqui
Palindrome.java

this program will request a word from the keyboard and determine if the word is a palindrome. Your output will display the 
original word, reverse word and if the word is or is not a palindrome. 

*/

import java.util.*;
 
class Palindrome
{
   public static void main(String args[])
   {
      String first; //string for original
      String second = ""; //string for reversed
      Scanner in = new Scanner(System.in);
 
      System.out.println("Enter a string to check if it is a palindrome");
      first = in.nextLine(); //user enters in string 
 
      int length = first.length(); //grabs length of original string
 
      for ( int i = length - 1; i >= 0; i-- ) //switches order of individual characters in the string
         second = second + first.charAt(i); //sets switched order to reversed string
 
      if (first.equals(second)) //if else statement, yes if palindrome
         {
         System.out.println("The Original entered string is : " + first);
         System.out.println("The Reversed string is : " + second);
         System.out.println("Entered string is a palindrome.");
         }
      else //no if not palindome. 
         {
         System.out.println("The Original entered string is : " + first);
         System.out.println("The Reversed string is : " + second);
         System.out.println("Entered string is not a palindrome.");
         }
   }
}	