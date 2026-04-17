import java.util.*;


public class Application {
    public static void main(String[] args) {
        Scanner cin = new Scanner(System.in);
        Game game;
        introduce();
        int option = cin.nextInt();
        cin.nextLine();
        switch (option){
            case 1:
                game = new Flames(cin);break;
            default:
                System.out.println("Invalid Option");return;
        }

        game.run();
    }

    public static void introduce(){
        System.out.println("===== Welcome to Loves Game ======");
        System.out.println("1 . FLAMES");
        System.out.print("\nSelect you option : ");
    }

}