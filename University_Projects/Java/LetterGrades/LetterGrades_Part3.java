/*
Aaleem Siddiqui
IST 331 section 2
01/21/2020
letter grades part 3

*/

import java.util.Scanner;
import java.util.ArrayList;
import java.io.BufferedReader;
import java.io.FileReader;
import java.io.IOException;
import java.nio.charset.StandardCharsets;
import java.nio.file.Files;
import java.nio.file.Paths;
import java.util.ArrayList;
import java.util.Collections;
import java.util.List;



public class LetterGrades_Part3
{
   public static void main(String[] args) throws IOException
      {
         // welcome message
         System.out.println("Enter your final calculated numeric grade."); 
         System.out.println("Enter -1 to exit");
         
         
         
         // open text file + create array for lines
         BufferedReader bufReader = new BufferedReader(new FileReader("letterGrades.txt"));
         ArrayList<String> listOfLines = new ArrayList<>();

         // adds to array line by line
         String line = bufReader.readLine();
         while (line != null) 
            {
               listOfLines.add(line);
               line = bufReader.readLine();
            }

         // close txt file
         bufReader.close();
          
          
         // create new array for letter grades 
         ArrayList<String> LG = new ArrayList<String>();
    
        
        
         // puts letter grades from first array to LG array
         for (int i = 1; i < 10; i++)
            {
               String str = listOfLines.get(i);
               String[] output = str.split("=");
               LG.add(output[1]);
            }
         
         
         // puts grade end points from first array to gep array
         ArrayList<String> gep = new ArrayList<String>();   
            
         for (int i = 0; i < 10; i++)
            {
               String ing = listOfLines.get(i);
               String[] output = ing.split("=");
               gep.add(output[0]);
            }
    
         
            
         
         
         
         // user input for grade
         double grade = 0;
         Scanner s = new Scanner(System.in);
      
      
      // -1 while loop to exit program   
         while (grade != -1)
            {   
               System.out.print("\nGrade: ");
               grade = s.nextDouble();
        
        
        // input validation
               while ((grade < -1) || (grade > 100)) 
                  {
                     System.out.println("The grade is invalid. Please try again.");
                     System.out.print("\nGrade: ");
                     grade = s.nextDouble();
                  }
        
         
        // if else statement for letter grades
               if ((grade >= Double.parseDouble(gep.get(1))) && (grade <= Double.parseDouble(gep.get(0))))
                  {
                     System.out.println("\nThe letter grade is an " + LG.get(0));
                  }
               else if (grade >= Double.parseDouble(gep.get(2)))
                  {
                     System.out.println("\nThe letter grade is an " + LG.get(1));
                  }   
               else if (grade >= Double.parseDouble(gep.get(3)))
                  {
                     System.out.println("\nThe letter grade is a " + LG.get(2));
                  }
               else if (grade >= Double.parseDouble(gep.get(4)))
                  {
                     System.out.println("\nThe letter grade is a " + LG.get(3));
                  }
               else if (grade >= Double.parseDouble(gep.get(5)))
                  {
                     System.out.println("\nThe letter grade is a " + LG.get(4));
                  }
               else if (grade >= Double.parseDouble(gep.get(6)))
                  {
                     System.out.println("\nThe letter grade is a " + LG.get(5));
                  }
               else if (grade >= Double.parseDouble(gep.get(7)))
                  {
                     System.out.println("\nThe letter grade is a " + LG.get(6));
                  }
               else if (grade >= Double.parseDouble(gep.get(8)))
                  {
                     System.out.println("\nThe letter grade is a " + LG.get(7));
                  }
               else if (grade >= Double.parseDouble(gep.get(9)))
                  {
                     System.out.println("\nThe letter grade is an " + LG.get(8));
                  }
            }
          // exit message
          System.out.print("\nGoodbye!");
      }
}