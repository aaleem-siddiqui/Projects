/*
Aaleem Siddiqui
IST242

Problem 2: [50 points]
*/

class user // user class
   {
      String name; // adding variables
      double salary;
      void tostring()
         {
            // output of user
            System.out.println("user// ");
            System.out.println("Name: " + name);
            System.out.println("Salary: " + salary);
            System.out.println();
         }
      user(String n,double s)
         {
            name = n;
            salary = s;
         }
   }

class Manager extends user // manager class (subclass of user)
   {
      String department; // adding department variable
      void tostring()
         {
            // output of manager
            System.out.println("Manager// ");
            System.out.println("Name: " + name);
            System.out.println("Department: " + department);
            System.out.println("Salary: " + salary);
            System.out.println();
         }
      Manager(String n, double s, String d)
         {
            super(n, s);
            department = d;
         }
   }

class Executive extends Manager // executive class (subclass of manager)
   {
      void tostring()
         {
            //output of executive
            System.out.println("Executive// ");
            System.out.println("Name: " + name);
            System.out.println("Department: " + department);
            System.out.println("Salary: " + salary);
            System.out.println();
         }
      Executive(String n, double s, String d)
         {
            super(n, s, d);
         }
   }



// main function
public class company
   {
      public static void main(String args[])
         {
            user user = new user("Aaleem", 40000); // inputs user info
            user.tostring(); // displays user info to user

            Manager manager = new Manager("John", 65000, "Research and Development"); //inputs manager info
            manager.tostring(); // displays manager info to user
   
            Executive executive = new Executive("Tony", 500000, "CEO"); //inputs exec info
            executive.tostring(); // displays executive info to user
}
}
