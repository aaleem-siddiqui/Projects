/*
Aaleem Siddiqui
IST242

 Problem 5: [40 points]

The user should supply an 8-digit number, and you should print out whether the number is valid or not. If it is not valid, you should print the value of the check digit that would make it valid. 
*/


import java.util.Scanner;

class CreditCardNumberCheck
{
   public static void main(String args[])
      {
         String n;
         
         
         while(true)
            {
               // welcome message / getting user input
               System.out.println("Welcome!");
               System.out.println("I will verify the CC number provided by the user.");
               System.out.println("Please make sure you enter a space in between every four digits");
               System.out.println("For example: 1234 5678");
               System.out.print("Let's get started, Please enter an 8 digit CC number: ");
               Scanner s = new Scanner(System.in);
               n = s.nextLine();
               
               // checking cc number format
               if(n.length() == 9)
                  {
                     break; //breaks while if format is correct
                  }
               else
                  { 
                     // returns to beginning of while of format is incorrect
                     System.out.println("Incorrect CC number format. Please read instructions and try again.");
                     System.out.println();
                     System.out.println();
                  
                  }
            }
        
         // grabbing every other character in the string
         int s = Integer.parseInt(n.charAt(1) + "") 
                + Integer.parseInt(n.charAt(3) + "")
                + Integer.parseInt(n.charAt(6) + "")
                + Integer.parseInt(n.charAt(8) + "");

         // doubling every character that wasn't used
         String s1 = ( 2 * Integer.parseInt(n.charAt(0) + "")) + "";
         String s2 = ( 2 * Integer.parseInt(n.charAt(2) + "")) + "";
         String s3 = ( 2 * Integer.parseInt(n.charAt(5) + "")) + "";
         String s4 = ( 2 * Integer.parseInt(n.charAt(7) + "")) + "";

         int t=0;
        
        
         // adding each digit of the doubled characters
         if(s1.length() == 2)
            {
               t = Integer.parseInt(s1.charAt(0) + "") 
               + Integer.parseInt(s1.charAt(1) + "");
            }
         else
            {
               t = Integer.parseInt(s1.charAt(0) + "");
            }
         if(s2.length() == 2)
            {
               t = t + Integer.parseInt(s2.charAt(0) + "")
               + Integer.parseInt(s2.charAt(1) + "");
            }
         else
            {
               t = Integer.parseInt(s2.charAt(0) + "");
            }
         if(s3.length() == 2)
            {
               t = t + Integer.parseInt(s3.charAt(0) + "") 
               + Integer.parseInt(s3.charAt(1) + "");
            }
         else
            {
               t = Integer.parseInt(s3.charAt(0) + "");
            }
         if(s4.length() == 2)
            {
               t = t + Integer.parseInt(s4.charAt(0) + "")
               + Integer.parseInt(s4.charAt(1) + "");
            }
         else
            {
               t = Integer.parseInt(s4.charAt(0) + "");
            }
            
         // sum of opposing digits
         int sum = t + s;
         
         //converting int to string
         String sumConvert = sum + "";
         
         
         if(sumConvert.charAt(1) == '0') // checks to see if second digit is 0
            {
               // if true, 
               System.out.println();
               System.out.println("The CC number provided is valid.");
            }
         else
            { 
               // if false,
               System.out.println();
               System.out.println("The CC number provided is NOT valid.");
            } 
    }
}