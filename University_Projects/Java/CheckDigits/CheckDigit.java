import java.util.Scanner;

public class CheckDigit {
{
    public static void main(String args[])
    {
        String n;
        while(true)
        {
            System.out.print("Enter the 8 digit credit card number: ");
            Scanner s=new Scanner(System.in);
            n=s.nextLine();
            if(n.length()==9)break;
            else System.out.println("Wrong length, enter again");
        }
        int s=Integer.parseInt(n.charAt(1)+"")+Integer.parseInt(n.charAt(3)+"")
                    +Integer.parseInt(n.charAt(6)+"")+Integer.parseInt(n.charAt(8)+"");

        String s1=(2*Integer.parseInt(n.charAt(0)+""))+"";
        String s2=(2*Integer.parseInt(n.charAt(2)+""))+"";
        String s3=(2*Integer.parseInt(n.charAt(5)+""))+"";
        String s4=(2*Integer.parseInt(n.charAt(7)+""))+"";

        int t=0;
        if(s1.length()==2)t=Integer.parseInt(s1.charAt(0)+"")+Integer.parseInt(s1.charAt(1)+"");
        else t=Integer.parseInt(s1.charAt(0)+"");
        if(s2.length()==2)t=t+Integer.parseInt(s2.charAt(0)+"")+Integer.parseInt(s2.charAt(1)+"");
        else t=Integer.parseInt(s2.charAt(0)+"");
        if(s3.length()==2)t=t+Integer.parseInt(s3.charAt(0)+"")+Integer.parseInt(s3.charAt(1)+"");
        else t=Integer.parseInt(s3.charAt(0)+"");
        if(s4.length()==2)t=t+Integer.parseInt(s4.charAt(0)+"")+Integer.parseInt(s4.charAt(1)+"");
        else t=Integer.parseInt(s4.charAt(0)+"");

        int t1=t+s;
        String t2=t1+"";
        if(t2.charAt(1)=='0')System.out.println("The number is valid");
        else System.out.println("The number is not valid");
    }
}