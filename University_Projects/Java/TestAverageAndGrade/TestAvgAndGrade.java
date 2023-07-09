import java.util.Scanner;

  
public class TestAvgAndGrade
{
   public static void main(String[] args)
   {
        Scanner keyboard = new Scanner(System.in); //create scanner for input data
        System.out.println("Enter test grade for student 1: ");//prompt user for test grade
        int studentOne = keyboard.nextInt();
	   
	   System.out.println("Enter test grade for student 2: ");//prompt user for test grade
        int studentTwo = keyboard.nextInt();
	   
	   System.out.println("Enter test grade for student 3: ");//prompt user for test grade
        int studentThree = keyboard.nextInt();
	   
	   System.out.println("Enter test grade for student 4: ");//prompt user for test grade
        int studentFour = keyboard.nextInt();
	   
	   System.out.println("Enter test grade for student 5: ");//prompt user for test grade
        int studentFive = keyboard.nextInt();
	   
	   
	   /////////////////////////////////////////////////////////////////////////////
	   
	   
	   System.out.println("The letter grades are as follows: ");
	   
	   if (studentOne < 60)
	   {
		 System.out.println("Student 1: F");
	   }
	   else if (studentOne <= 69)
	   {
		 System.out.println("Student 1: D");
	   }
	   else if (studentOne <= 79)
	   {
		 System.out.println("Student 1: C");
	   }
	   else if (studentOne <= 89)
	   {
		 System.out.println("Student 1: B");
	   }
	   else
	   {
		 System.out.println("Student 1: A");
	   }
	   
	   ////////////////////////////////////////////////////////////////////////////////
	   
	    if (studentTwo < 60)
	   {
		 System.out.println("Student 2: F");
	   }
	   else if (studentTwo <= 69)
	   {
		 System.out.println("Student 2: D");
	   }
	   else if (studentTwo <= 79)
	   {
		 System.out.println("Student 2: C");
	   }
	   else if (studentTwo <= 89)
	   {
		 System.out.println("Student 2: B");
	   }
	   else
	   {
		 System.out.println("Student 2: A");
	   }
	   
	    ////////////////////////////////////////////////////////////////////////////////
	   
	    if (studentThree < 60)
	   {
		 System.out.println("Student 3: F");
	   }
	   else if (studentThree <= 69)
	   {
		 System.out.println("Student 3: D");
	   }
	   else if (studentThree <= 79)
	   {
		 System.out.println("Student 3: C");
	   }
	   else if (studentThree <= 89)
	   {
		 System.out.println("Student 3: B");
	   }
	   else
	   {
		 System.out.println("Student 3: A");
	   }
	   
	    ////////////////////////////////////////////////////////////////////////////////
	   
	    if (studentFour < 60)
	   {
		 System.out.println("Student 4: F");
	   }
	   else if (studentFour <= 69)
	   {
		 System.out.println("Student 4: D");
	   }
	   else if (studentFour <= 79)
	   {
		 System.out.println("Student 4: C");
	   }
	   else if (studentFour <= 89)
	   {
		 System.out.println("Student 4: B");
	   }
	   else
	   {
		 System.out.println("Student 4: A");
	   }
		   
		 ////////////////////////////////////////////////////////////////////////////////
	   
	    if (studentFive < 60)
	   {
		 System.out.println("Student 5: F");
	   }
	   else if (studentFive <= 69)
	   {
		 System.out.println("Student 5: D");
	   }
	   else if (studentFive <= 79)
	   {
		 System.out.println("Student 5: C");
	   }
	   else if (studentFive <= 89)
	   {
		 System.out.println("Student 5: B");
	   }
	   else
	   {
		 System.out.println("Student 5: A");
	   }
	
	int added = studentOne + studentTwo + studentThree + studentFour + studentFive;
	int calcAverage = added / 5;	   
	System.out.println("The Average grade was: " + calcAverage);
		   
   }
}