import java.util.Scanner;
import java.util.*;
import javax.swing.JOptionPane; // Needed for dialogue box
  
public class WordGame
{
   public static void main(String[] args)
   {

  
   //initialize variables
 
   Scanner dd = new Scanner(System.in);
   
   
  
   
   String name = JOptionPane.showInputDialog("Enter your name:");
   
   String age = JOptionPane.showInputDialog("Enter your age:");
   
   String cityName = JOptionPane.showInputDialog("Enter the name of a city:");
   
   
   String collegeName = JOptionPane.showInputDialog("Enter the name of a college:");
   
   
   String profession = JOptionPane.showInputDialog("Enter profession:");
   
   String animal = JOptionPane.showInputDialog("Enter a type of animal:");
   
   
   String petName = JOptionPane.showInputDialog("Enter a pet name:");
   
  
      
     
         
	
	   
   
     // Display the results.
      System.out.println("There once was a person named " + name + " who lived in " + cityName + ". At the age of " + age + ", " + name + " went to college at " + collegeName + ". " + name + " graduated and went to work as a " + profession + ". Then, " + name + " adopted a(n) " + animal + " named " + petName + " and they both lived happily ever after!" );
      
        
      
   }
}

      
      
   

