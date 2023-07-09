/*
Aaleem Siddiqui
IST242

Problem 1: [25 points]
*/

import java.util.Scanner;
import java.io.File;
import java.io.FileNotFoundException;
import java.io.PrintWriter;


public class fileReadAndWrite 
    {
      public static void main(String[] args) // main function
         {
            writeToFile(); // write to file function
            
            String stuff = readFromFile("hello.txt"); // read from file function

            System.out.println(stuff); // outputs string
         }



      // write to file function
      public static void writeToFile() 
         {
            File file = new File("hello.txt"); // creates file hello.txt

            try (PrintWriter out = new PrintWriter(file)) 
               {
                  out.write("Hello, World!"); // prints hello world to file
               } 
            catch (FileNotFoundException e) 
               {
                  System.out.println("This file is not found."); // if file fails to create or gets deleted
               }
         }
      
      // read from file function
      public static String readFromFile(String filename) 
         {
            File file = new File(filename);
            
            String stuff = null; // creates empty string

            try (Scanner input = new Scanner(file)) 
               {
                  stuff = input.nextLine(); // reads content from file
               } 
            catch (FileNotFoundException e) 
               {
                  System.out.println("This file is not found."); // if file fails to create or gets deleted
               }

            return stuff;

         }


    }