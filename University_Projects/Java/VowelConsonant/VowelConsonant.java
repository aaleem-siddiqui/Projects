/*
Aaleem Siddiqui
VowelConsonant.java
This is a program that prompts the user to provide a single character from the alphabet. Print vowel or consonant,
depending on the user input. 



*/

import java.io.*;
import java.util.Scanner;  // Needed for the Scanner class
import javax.swing.JOptionPane; // Needed for dialogue box

  
public class VowelConsonant
{
   public static void main(String[] args)throws Exception
   {
   
       Scanner keyboard = new Scanner(System.in); //scanner for user input
       String s = JOptionPane.showInputDialog("Please provide a single character from the alphabet: "); //prompt user for input
       int stringSize = s.length(); //calculates length of string
       char ch = s.charAt(0); //grabs first character from string
    
        
        if(stringSize == 1)//if statement (only goes through if size of string is equal to one)
            switch(ch)//switch statement for any vowel entered
            {
                  case 'a': 
                  System.out.println("The given character "+ch+" is vowel");
                  break;
 
                  case 'e':
                  System.out.println("The given character "+ch+" is vowel");
                  break;
 
                  case 'i':
                  System.out.println("The given character "+ch+" is vowel");
                  break;
 
                  case 'o':
                  System.out.println("The given character "+ch+" is vowel");
                  break;
 
                  case 'u':
                  System.out.println("The given character "+ch+" is vowel");
                  break;
 
                  default: //any consonant entered would become an outlier and filtered to default
                  System.out.println("The given character "+ch+" is consonant");
                  break;
            }
         else
         System.out.println("You did not enter a single letter"); //indication of incorrect entry
        
    }
}