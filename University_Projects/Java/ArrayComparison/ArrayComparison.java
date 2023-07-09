/*
Aaleem Siddiqui
IST242

Problem 2: [10 points]
*/

import java.util.Scanner;

public class ArrayComparison 
{
    public static void main(String[] args) 
    {
        // reading user input
        Scanner input = new Scanner(System.in);


        // adding user input to first array
        int[] firstArray = new int[5];
        for (int i = 0; i < firstArray.length; i++) 
        {
            System.out.printf("Give me integer #%d for first array: ", i + 1);
            firstArray[i] = input.nextInt();
        }
        
         
        // adding user input to second array 
        int[] secondArray = new int[5];
        for (int i = 0; i < secondArray.length; i++) 
        {
            System.out.printf("Give me integer #%d for the second array: ", i + 1);
            secondArray[i] = input.nextInt();
        }

        input.close(); 
         
        // running comparison method and displaying output 
        boolean tryCompare = compare(firstArray, secondArray);
        System.out.printf("Do the first and second array have the same elements in some order? %s", tryCompare);
    }



   // comparison method
    public static boolean compare(int[] a, int[] b) 
    {
        boolean compareSameNumbers = false;
        for (int i = 0; i < a.length; i++) 
        {
            for (int j = 0; j < b.length; j++) 
            {
                if (a[i] == b[j]) 
                {
                    compareSameNumbers = true;
                }
            }

            if (!compareSameNumbers) 
            {
                return false;
            }
        }

        return true;
    }
}