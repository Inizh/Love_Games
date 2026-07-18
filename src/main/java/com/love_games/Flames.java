package com.love_games;

import java.util.Arrays;
import java.util.HashMap;
import java.util.LinkedList;
import java.util.Map;

/**
 * FLAMES relationship calculator — same algorithm as the CLI game.
 */
public final class Flames {

    private static final Map<Character, String> RESULTS = Map.of(
            'F', "FRIEND",
            'L', "LOVE",
            'A', "AFFECTION",
            'M', "MARRIAGE",
            'E', "ENEMY",
            'S', "SISTER"
    );

    private static final Map<Character, String> DESCRIPTIONS = Map.of(
            'F', "A warm friendship is written in the stars.",
            'L', "True love is blooming between you two!",
            'A', "There's a soft affection drawing you closer.",
            'M', "Wedding bells? The universe says yes.",
            'E', "Sparks fly — but maybe not the romantic kind.",
            'S', "A bond as close as family — sisterly love."
    );

    private Flames() {}

    public static Result calculate(String herName, String hisName) {
        if (herName == null || hisName == null) {
            return Result.empty();
        }
        String her = herName.trim();
        String his = hisName.trim();
        if (her.isEmpty() || his.isEmpty()) {
            return Result.empty();
        }

        int unique = uniqueLetterCount(her, his);
        char answer = resolve(unique);
        String label = RESULTS.getOrDefault(answer, "No result found");
        String description = DESCRIPTIONS.getOrDefault(answer, "Try different names.");
        return new Result(answer, label, description, unique, her, his);
    }

    private static int uniqueLetterCount(String herName, String hisName) {
        Map<Character, Integer> hermap = new HashMap<>();
        Map<Character, Integer> hismap = new HashMap<>();
        countLetters(hermap, herName.toUpperCase());
        countLetters(hismap, hisName.toUpperCase());

        hismap.forEach((key, value) -> hermap.merge(key, value, Flames::absDifference));

        int total = 0;
        for (int value : hermap.values()) {
            total += value;
        }
        return total;
    }

    private static void countLetters(Map<Character, Integer> map, String name) {
        for (int i = 0; i < name.length(); i++) {
            char c = name.charAt(i);
            if (!Character.isLetter(c)) {
                continue;
            }
            map.put(c, map.getOrDefault(c, 0) + 1);
        }
    }

    private static Integer absDifference(Integer a, Integer b) {
        int c = a - b;
        return (c > 0) ? c : -c;
    }

    private static char resolve(int unique) {
        if (unique <= 0) {
            return ' ';
        }
        LinkedList<Character> flames = new LinkedList<>(Arrays.asList('F', 'L', 'A', 'M', 'E', 'S'));
        int pointer = 0;
        while (flames.size() > 1) {
            pointer = (pointer + unique - 1) % flames.size();
            flames.remove(pointer);
        }
        return flames.peek();
    }

    public record Result(
            char letter,
            String label,
            String description,
            int uniqueCount,
            String herName,
            String hisName
    ) {
        public boolean isEmpty() {
            return label == null || label.isEmpty() || letter == ' ';
        }

        static Result empty() {
            return new Result(' ', "", "Please enter both names.", 0, "", "");
        }
    }
}
