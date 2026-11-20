/// FLAMES relationship calculator.
///
/// Same counting and elimination rules as the JavaFX app: strike shared
/// letters, then walk the remaining count around F-L-A-M-E-S.
library;

class FlamesOutcome {
  const FlamesOutcome(this.letter, this.label, this.description);

  final String letter;
  final String label;
  final String description;
}

class FlamesResult {
  const FlamesResult({
    required this.letter,
    required this.label,
    required this.description,
    required this.uniqueCount,
    required this.herName,
    required this.hisName,
  });

  final String letter;
  final String label;
  final String description;
  final int uniqueCount;
  final String herName;
  final String hisName;

  bool get isEmpty => label.isEmpty || letter == ' ';

  static const empty = FlamesResult(
    letter: ' ',
    label: '',
    description: 'Please enter both names.',
    uniqueCount: 0,
    herName: '',
    hisName: '',
  );
}

abstract final class Flames {
  static const outcomes = <FlamesOutcome>[
    FlamesOutcome('F', 'FRIEND', 'A warm friendship is written in the stars.'),
    FlamesOutcome('L', 'LOVE', 'True love is blooming between you two!'),
    FlamesOutcome(
      'A',
      'AFFECTION',
      "There's a soft affection drawing you closer.",
    ),
    FlamesOutcome('M', 'MARRIAGE', 'Wedding bells? The universe says yes.'),
    FlamesOutcome(
      'E',
      'ENEMY',
      'Sparks fly — but maybe not the romantic kind.',
    ),
    FlamesOutcome('S', 'SISTER', 'A bond as close as family — sisterly love.'),
  ];

  static final Map<String, FlamesOutcome> _byLetter = {
    for (final outcome in outcomes) outcome.letter: outcome,
  };

  static FlamesResult calculate(String herName, String hisName) {
    final her = herName.trim();
    final his = hisName.trim();
    if (her.isEmpty || his.isEmpty) {
      return FlamesResult.empty;
    }

    final unique = _uniqueLetterCount(her, his);
    final answer = _resolve(unique);
    final outcome = _byLetter[answer];
    return FlamesResult(
      letter: answer,
      label: outcome?.label ?? 'No result found',
      description: outcome?.description ?? 'Try different names.',
      uniqueCount: unique,
      herName: her,
      hisName: his,
    );
  }

  static int _uniqueLetterCount(String herName, String hisName) {
    final herMap = <String, int>{};
    final hisMap = <String, int>{};
    _countLetters(herMap, herName.toUpperCase());
    _countLetters(hisMap, hisName.toUpperCase());

    hisMap.forEach((key, value) {
      final existing = herMap[key];
      if (existing == null) {
        herMap[key] = value;
      } else {
        final difference = existing - value;
        herMap[key] = difference > 0 ? difference : -difference;
      }
    });

    var total = 0;
    for (final value in herMap.values) {
      total += value;
    }
    return total;
  }

  static void _countLetters(Map<String, int> map, String name) {
    for (var i = 0; i < name.length; i++) {
      final letter = name[i];
      if (!_letter.hasMatch(letter)) {
        continue;
      }
      map[letter] = (map[letter] ?? 0) + 1;
    }
  }

  static final RegExp _letter = RegExp(r'\p{L}', unicode: true);

  static String _resolve(int unique) {
    if (unique <= 0) {
      return ' ';
    }
    final flames = <String>['F', 'L', 'A', 'M', 'E', 'S'];
    var pointer = 0;
    while (flames.length > 1) {
      pointer = (pointer + unique - 1) % flames.length;
      flames.removeAt(pointer);
    }
    return flames.first;
  }
}
