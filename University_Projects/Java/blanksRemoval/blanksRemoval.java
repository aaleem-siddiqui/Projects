/*
Aaleem Siddiqui
IST242

Problem 2: [25 points]

Write a program that reads a file, removes any blank lines, and writes the non-blank lines back to the same file.

*/



import java.io.*;
import java.util.Scanner;
 
public class blanksRemoval 
   {
      public static void main(String[] args) throws IOException // main function
         {
         
            // reads original text doc
            Scanner scanner = new Scanner(System.in);
            System.out.println("Reading original text document... "); // placeholder
            String inputTXT = "withBlanks.txt"; // make sure to create a text doc with this name or alter the code
                               
                               
            BufferedReader inputFileReader = new BufferedReader(new FileReader(inputTXT));
            String inputLine;
            System.out.println("Writing original text document without blanks... "); // placeholder
            String withoutBlanks = "withoutBlanks.txt";  
            
                       
            
            PrintWriter outputTXT = new PrintWriter(new FileWriter(withoutBlanks)); 
            
            while((inputLine = inputFileReader.readLine()) != null)  // if line is not empty, write to file
            {
                if(inputLine.length() == 0) 
                    continue;
                outputTXT.println(inputLine);
            } 
            
           outputTXT.close();
    }
}