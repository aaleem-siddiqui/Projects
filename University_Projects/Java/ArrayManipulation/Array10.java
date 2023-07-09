/*
Aaleem Siddiqui
array10.java

this program initializes an array with ten random integers and then prints four lines; every element at an even index, every
element with an even value, all elements in reverse order, and the first and last element. 

*/

import java.util.*;
 
class Array10
{
  public static void main(String[] args)
     {
            
            Random random = new Random(); //needed for random elements in array
            int arr[] = new int[10]; //create array with 10 open slots
            
            ///////////////////////////////////////10 INTEGERS
            System.out.print("Array with ten random integers: ");
            for (int i = 0; i < arr.length; i++) 
               {
                  arr[i] = random.nextInt(50); //fills array with integers from 1-50
                  System.out.print(arr[i] + ", ");
               }
               
               
            ///////////////////////////////////////LINE 1   
            System.out.println();//new line
            System.out.print("Every element at an even index: ");
            for (int i = 0; i < arr.length; i++) 
               {
                  if(i % 2 == 0) //if the elements index is divisible by two it is displayed
                     {
                        System.out.print(arr[i] + " at " + i + ", ");
                     }
               }
            
            ///////////////////////////////////////LINE 2   
            System.out.println();//new line
            System.out.print("Every element with an even value: ");
            
            for (int i = 0; i < arr.length; i++) 
               {
                  if(arr[i] % 2 == 0) //if the element is divisible by two it is displayed
                     {
                        System.out.print(arr[i] + ", ");
                     }
               }
               
            ///////////////////////////////////////LINE 3   
            System.out.println();//new line   
            System.out.print("All elements in reverse order: ");
            for(int i = arr.length - 1; i >= 0; i--)// i-- would reverse the index and display the array backwards
               {
                   System.out.print(arr[i] + ", ");
               }
               
            ///////////////////////////////////////LINE 4   
            System.out.println(); //new line
            System.out.print("First Element is " + arr[0] + " and last element is " + arr[arr.length - 1]); //displays first and last via index

    }
}