import java.util.*;

class Game {
    Scanner cin;
    Game(Scanner in){
        cin = in;

    }

    public void run() {}

}

final class Flames extends Game{
    public String herName;
    public String hisName;
    HashMap<Character , String > map = new HashMap<>();

    Flames(Scanner cin){
        super(cin);
        map.put('F' , "FRIEND");
        map.put('L' , "LOVE");
        map.put('A' , "AFFECTION");
        map.put('M' , "MARRIAGE");
        map.put('E' , "ENEMY");
        map.put('S' , "SISTER");
    }

    public void run(){
        System.out.print("What's Her Name : ");
        herName = cin.nextLine().trim().toLowerCase();
        System.out.print("What's His Name : ");
        hisName = cin.nextLine().trim().toLowerCase();
        System.out.println("\nHmm...\n");
        int unique = uniqueLeter();
        char answer = logic(unique);
        System.out.println(map.getOrDefault(answer, "No result found for " + answer));
    }

    private int uniqueLeter(){
        Map<Character , Integer> hismap = new HashMap<>();
        Map<Character , Integer> hermap = new HashMap<>();
        convertStringtoMap(hermap, herName.toUpperCase());
        convertStringtoMap(hismap, hisName.toUpperCase());
        
        hismap.forEach((key , value ) -> hermap.merge(key , value , this::absDifferance));
        
        int total = 0;
        for (int value : hermap.values()) {
            total += value;
        }
        return total;
    }

    private void convertStringtoMap(Map<Character, Integer> hismap, String hisName) {
        for(int i = 0; i <  hisName.length() ; i++){
            char c = hisName.charAt(i);
            if (!Character.isLetter(c)) continue;
            hismap.put(c, hismap.getOrDefault(c, 0) + 1);
        }
        hismap.remove(' ');
    }

    private Integer absDifferance(Integer a, Integer b) {
        int c = a - b;
        return (c > 0) ? c : -c;
    }

    private Character logic(int unique){
        if (unique <= 0) return ' ';
        LinkedList<Character> flames = new LinkedList<>(Arrays.asList('F' , 'L' , 'A' , 'M' , 'E' , 'S'));
        int pointer = 0;
        while(flames.size() > 1){
            pointer = (pointer + unique - 1) % flames.size();
            flames.remove(pointer);
        }
        return flames.peek();
    }
}
