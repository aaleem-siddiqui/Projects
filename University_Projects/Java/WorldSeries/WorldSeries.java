/*
Aaleem Siddiqui
WorldSeries.java
this program lets the user enter the name of a team, and then dsplays the number of times that team has won the World Series 
in the time period from 1903 through 2009.

pseucode:
-scan in txt file
-prompt user for team name
-scan each line for team name
-while team name matches line, add to counter
-display counter(number of times team won)

*/

import java.util.Scanner; 
import java.io.*; 

public class WorldSeries
   { 
      public static void main(String[] args) throws IOException 
         { 
            Scanner scan = new Scanner(System.in); 
            Scanner scanFile = new Scanner(new File("worldserieswinners.txt")); //file  

            System.out.print("Enter team name: ");  //prompt user for team name
            String strTeam = scan.nextLine(); //userinput string

            int a = 0; //initiate counter

            while (scanFile.hasNext()) 
               { 
                  String s = scanFile.nextLine(); 
                  System.out.println(s); 
                     if ( s.equals( strTeam ) )//comparison
                        { 
                           a++; //counter
                        } 
               } 

            scanFile.close(); 
            System.out.println(strTeam + " have won the World Series " + a + " times."); //displays #of times team won 
         } 
   }