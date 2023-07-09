import java.util.Scanner;

public class timeProgram
   {
      // time name method
      public static String getTimeName(int hours, int minutes)
         {
         
            // declaring string
            String name = "";

            if((hours >= 1 && hours <= 12) && (minutes >= 0 && minutes <= 59))
               {
               
                  // numbers for words
                  String hourminute []={"", "one", "two", "three", "four", "five", "six","seven", "eight", "nine","ten","eleven","twelve","thirteen","fourteen","fifteen", "sixteen","seventeen","eighteen",
                  "nineteen","twenty","twenty one", "twenty two", "twenty three", "twenty four", "twenty five", "twenty six","twenty seven","twenty eight", "twenty nine"};
                  String hour;

                  if (hours==12)
                     {
                        hour = hourminute [1];
                     }
                  else
                     {
                        hour = hourminute[hours+1];  
                     }
                     
                  // if else statement for 15 min increments   
                  if (minutes==0)
                     {
                        name = hourminute[hours]+" o'clock";
                     }
                  else if (minutes==15)
                     {
                        name = "quarter past "+hourminute[hours];
                     }
                  else if (minutes==30)
                     {
                        name = "half past "+hourminute[hours];
                     }
                  else if (minutes==45)
                     {
                        name = "a quarter to "+hour;
                     }
                  else if (minutes<30)
                     {
                        name = hourminute[minutes]+" minutes past "+hourminute[hours];   
                     }
                  else
                     {
                        name = hourminute[60-minutes]+" to "+hour;
                     }
               }
            // validating format
            else
               {
                  name = "The format entered is invalid";
               }
         return name;

      }

  

   public static void main(String[] args) 
      {
         // intro message
         System.out.println("This program will return the English name for a point in time that you provide!");
         System.out.println("Let's start!");
         
         // user input for hours / minutes
         Scanner s = new Scanner(System.in);
         System.out.print("\nPlease enter the Hours: ");
         int hour = s.nextInt();
         System.out.print("\nPlease enter the Minutes: ");
         int min = s.nextInt();
         
         // using timename method
         String timeName = getTimeName(hour,min);
         
         // final output
         System.out.println("\nThe time is "+ timeName);
      }

}