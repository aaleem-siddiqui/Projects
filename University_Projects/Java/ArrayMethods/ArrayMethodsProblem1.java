/*
Aaleem Siddiqui
IST242

Problem 1: [50 points]
*/

import java.util.Arrays;
import java.util.Random;
class ArrayMethods {


// method to swap first and last elements in the array
   public static void swapFirstLast(int[] values)
   {
       int temp = values[0];
       values[0] = values[values.length-1];
       values[values.length-1] = temp;
   }

 
// method to shift elements to the right
   public static void rotateRight(int[] values)
   {
       for (int j = 0; j < 1; j++) 
       {
           int a = values[values.length - 1];
           int i;
           for (i = values.length - 1; i > 0; i--)
               values[i] = values[i - 1];
           values[i] = a;
       }

   }


// method to replace even integers with 0
   public static void replaceEvent(int[] values) 
   {
       for(int i=0; i<values.length; i++) 
       {
           if(values[i] % 2 == 0) 
           {
               values[i] = 0;
           }
       }
   }


// method to replace integers with largest neighboring
   public static void replaceWithLargestNeighbor(int[] values) 
   {
       for(int i=1;i <values.length-1; i++) 
       {
           values[i] = Math.max(values[i-1], values[i+1]);

       }
   }


// method to remove the two middle integers (because the array is an even amount of numbers)
   public static int[] removeMiddle(int[] values) 
   {
       int result[];
       int len = values.length;
       if(len % 2 == 0) 
       {
           result = new int[len-2];
           int k=0;
           for(int i=0; i<len; i++) 
           {
               if(i != len/2 && i != len/2 - 1) 
               {
                   result[k++] = values[i];
               }
           }
       } 
       else 
       {
           result = new int[len-1];
           int k=0;
           for(int i=0; i<len; i++) 
           {
               if(i != len/2 ) 
               {
                   result[k++] = values[i];
               }
           }  
       }
       return result;
   }


// method to move even numbers to the front (they were all turned to 0 anyways)
   public static void moveEvenToFront(int[] values) 
   {
       int temp=0;
       int a=0;
       
       for(int i=0; i<values.length; i++)
       {
           if(values[i] % 2 == 0)
           {
               for (int j=i; j>a; j--)
               {
                   temp = values[j-1];
                   values[j-1] = values[j];
                   values[j] = temp;
               }
               a ++;
           }
       }
   }


// method to read the second largest integer in the array
   public static int getSecondLargest(int[] values) 
   {

       int i, first, second;
       int len = values.length;

       first = second = Integer.MIN_VALUE;

       for (i = 0; i < len ; i++)
       {
           if (values[i] > first)
           {
               second = first;
               first = values[i];
           }
           else if (values[i] > second && values[i] != first)
               second = values[i];
       }
       return second;
   }


// method to return if the array is in order
   public static boolean inOrder(int[] values) 
   {
       for(int i=1; i<values.length; i++) 
       {
           if(values[i] < values[i-1])
               return false;
       }
       return true;
   }


// method to return if the array has adjacent duplicates
   public static boolean adjacentDupes(int[] values) 
   {
       for(int i=1; i<values.length; i++) 
       {
           if(values[i] == values[i-1])
                return true;
       }
       return false;
   }


// method to return if the array has duplicates other than those that are adjacent
   public static boolean containsDuplicates(int[] values) 
   {
       Arrays.sort(values);
       
       for(int i=1; i<values.length; i++) 
       {
           if(values[i] == values[i-1])
               return true;
       }
       return false;
   }
}


///////////////////////////////////////////////////////////////////////////////////////////
// main method

public class ArrayMethodsProblem1 
{

// creating the array
   public static void printArray(int[] values) 
   {
       System.out.println(Arrays.toString(values));
   }


// filling the array with random integers
   public static void main(String[] args) 
   {
       int[] a = new int[10]; 
       Random random = new Random();

       for(int i=0; i<10; i++) 
       {
           int rand = random.nextInt(50);
           a[i] = rand;
       }




       System.out.println("This is the original array:");
       System.out.println(Arrays.toString(a));
       System.out.println();
       
       


       //printing swapFirstLast() method

       System.out.println("Before swapping the first and last integer:");
       printArray(a);
       ArrayMethods.swapFirstLast(a);
       System.out.println("After:");
       printArray(a); 
       System.out.println();

       
       
       
       
       
       //printing rotateRight() method

       System.out.println("Before shifting integers to the right:");
       printArray(a);
       ArrayMethods.rotateRight(a);
       System.out.println("After:");
       printArray(a); 
       System.out.println();

       
       
       //printing replaceEvent() method

       System.out.println("Before setting even integers to zero:");
       printArray(a);
       ArrayMethods.replaceEvent(a);
       System.out.println("After:");
       printArray(a); 
       System.out.println(); 
       
       
       
       //printing replaceWithLargestNeighbor() method

       System.out.println("Before replacing integers with the larger of its two neighbors:");
       printArray(a);
       ArrayMethods.replaceWithLargestNeighbor(a);
       System.out.println("After:");
       printArray(a);
       System.out.println();
       
       
       
       
       
       
       //printing removeMiddle() method

       System.out.println("Before removing the middle two integers");
       printArray(a);
       a = ArrayMethods.removeMiddle(a);
       System.out.println("After:");
       printArray(a); 
       System.out.println();

      
      
       //printing moveEvenToFront() method

       System.out.println("Before moving even integers to the front:");
       printArray(a);
       ArrayMethods.moveEvenToFront(a);
       System.out.println("After:");
       printArray(a); 
       System.out.println();
      
      
      
      
      
       //printing getSecondLargest() method

       System.out.println("Current array:");
       printArray(a);
       int secLargest = ArrayMethods.getSecondLargest(a);
       System.out.println();
       System.out.println("The second largest integer is " + secLargest + ".");

      
       //printing inOrder() method
       
       boolean sorted = ArrayMethods.inOrder(a);
       System.out.println("Are the integers in order? " + sorted);
    


       //printing adjacentDupes() method

       boolean adjDup = ArrayMethods.adjacentDupes(a);
       System.out.println("Do the integers have adjacent duplicates? " + adjDup);
       

       //printing containsDuplicates() method

       boolean dup = ArrayMethods.containsDuplicates(a);
       System.out.println("Do the integers have duplicate elements that are not adjacent? " + dup);
       System.out.println();

    


   }

}