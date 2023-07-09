import java.util.Scanner;
import java.util.*;
  
public class ClassGenderPercentages
{
   public static void main(String[] args)
   {

  
   //initialize variables
 
   Scanner dd = new Scanner(System.in);
   
  
   
   System.out.println("Enter number of males registered in class.");
   int males = dd.nextInt();
   System.out.println("Enter number of females registered in class.");
   int females = dd.nextInt();
  
      
     
         
	double total = males + females;
	double malePercentage = ( males / total ) * 100;
	double femalePercentage = ( females / total ) * 100;
	   
   
     // Display the results.
      System.out.println("Male Percentage is:" + malePercentage + "%");
      System.out.println("Female Percentgae is:" + femalePercentage + "%");
        
      
   }
}
