/*
Aaleem Siddiqui
IST242

Problem 3: [20 points]
*/

import java.util.Scanner;

public class passwordValidation 
{
    public static void main(String[] args) 
    {
    // intro message
    System.out.println("Welcome to the password validation program");
    System.out.println("Your password MUST meet all of the following rules:");
    System.out.println("\tThe password must be at least 8 characters long.");
    System.out.println("\tThe password must have at least one uppercase and one lowercase letter.");
    System.out.println("\tThe password must have at least one digit.");
    System.out.println();



    
      
        // user input
        Scanner in = new Scanner(System.in);
        System.out.print("Please enter your password: ");
        String password = in.nextLine();
        
        // confirm user input for comparison
        System.out.print("Please re-enter your password to confirm: ");
        String confirm = in.nextLine();
        
        
        // comparing pw to confirm pw , if invalid, sets to while loop
        boolean condition;
        condition = isValid(password);
        while (!password.equals(confirm) || (!condition)) 
        {
            System.out.println("The password is invalid");
            System.out.print("Please enter the password again : ");
            String Password = in.nextLine();
            System.out.print("Please re-enter the password to confirm : ");
            String Confirm = in.nextLine();
        }
        
        
        // system output if pw is valid or not
        if (isValid(password)) 
        {
            System.out.println("The password is valid.");
        }
        else
            System.out.println("The password is NOT valid, please re-run the program and try again.");
     }


    public static boolean isValid(String password) 
    {
      
      // setting conditions
      Boolean upper = false;
      Boolean lower = false;
      Boolean digit = false;

      // password length must be at least 8 characters
      if (password.length() < 8) 
         { 
            return false;
         }


      for (int i = 0; i < password.length(); i++) 
         { 
            if (Character.isUpperCase(password.charAt(i))) 
               {
                  upper = true; // checks for uppercase char
               }
            else if (Character.isLowerCase(password.charAt(i))) 
               {
                  lower = true; // checks for lowercase char
               }
            else if (Character.isDigit(password.charAt(i))) 
               {
                  digit = true; // checks for integer
               }
         }

   // returns if all conditions are true
    return (upper && lower && digit); 
   }
}
