/*
Aaleem Siddiqui
IST242

Problem 1: [50 points]
*/


class car //created class for car
   {

     
      private double fuel_eff,gas,distance,gas_cons; // creating variables

      car(double eff) //setting variables to zero
         {
            distance = 0;
            gas = 0;
            gas_cons = 0;
            fuel_eff = eff;
         }

      public void addGas(double amt) //adding gas to car
         {
            gas += amt;
         }

      public void drive(double dis) //car driving distance
         {
            double gallon_con;
            distance += dis;
            gallon_con = dis / fuel_eff;
            gas_cons += gallon_con;
            gas -= gallon_con;
         }

      public double fuelInTank() //returns the amount of gas in tank
         {
            return gas;
         }

      public double fuelEfficiency()// returns fuel efficiency
         {
            return fuel_eff;
         }

      public double distanceTrav() // returns units traveled
         {
            return distance;
         }

      public double fuelConsumed() // returns fuel consumed
         {
            return gas_cons;
         }


   }

class actualCar // main method
   {
      public static void main(String args[])
         {
            car myHybrid = new car(50); // 50 mpg

            myHybrid.addGas(20); // adding 20 gallons to tank

            myHybrid.drive(100); // driving car 100 miles

        

            
            
            // outputting results to user

            System.out.println("Fuel Efficiency: " + myHybrid.fuelEfficiency());
            
            System.out.println("Fuel Consumed: " + myHybrid.fuelConsumed()); 
            
            System.out.println("Distance Travelled: " + myHybrid.distanceTrav()); 
            
            System.out.println("Fuel left in tank: " + myHybrid.fuelInTank()); 
         }
   }

