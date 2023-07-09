/*
Aaleem Siddiqui
IST242

Problem 4: [25 points]

friends hashmap
*/

import java.util.ArrayList;
import java.util.HashMap;
import java.util.Scanner;

public class friendsHashMap 
   {
      // main function
      public static void main(String[] args) 
         { 
            HashMap<String, ArrayList<String>> people = new HashMap<>(); // hashmap

            ArrayList<String> suesFriends = new ArrayList<>(); // list for sue
            suesFriends.add("Bob"); // adding to sues list
            suesFriends.add("Jose");
            suesFriends.add("Alex");
            suesFriends.add("Cathy");
     
            ArrayList<String> cathysFriends = new ArrayList<>(); //list for cathy
            cathysFriends.add("Bob"); // adding to cathys list
            cathysFriends.add("Alex");

            ArrayList<String> bobsFriends = new ArrayList<>(); // list for bob
            bobsFriends.add("Alex"); // adding to bobs list
            bobsFriends.add("Jose");
            bobsFriends.add("Jerry");
      
            // linking lists to names
            people.put("Sue", suesFriends);
            people.put("Cathy", cathysFriends);
            people.put("Bob", bobsFriends);

            Scanner scanner = new Scanner(System.in);
      
            // getting user input for name
            System.out.print("Enter a name: ");
            String name = scanner.next();
            System.out.println();

            if(people.containsKey(name)) 
               {
                  System.out.println(name + " is friends with:"); //program output
                  System.out.println(people.get(name));
               }
           else
               {
                  System.out.println("This name is not in the HashMap. Rerun the program and try again."); // if the name is not in hashmap
               }          
         }
    }