import 'package:flutter_test/flutter_test.dart';
import 'package:loves_games/flames/flames.dart';

void main() {
  test('rejects a blank name', () {
    final result = Flames.calculate('  ', 'Asha');
    expect(result.isEmpty, isTrue);
    expect(result.description, 'Please enter both names.');
  });

  test('A and B resolve to enemy', () {
    final result = Flames.calculate('A', 'B');
    expect(result.letter, 'E');
    expect(result.label, 'ENEMY');
    expect(result.uniqueCount, 2);
    expect(result.description, 'Sparks fly — but maybe not the romantic kind.');
  });

  test('identical letters have no FLAMES result', () {
    final result = Flames.calculate('Ann', 'ann');
    expect(result.isEmpty, isTrue);
    expect(result.letter, ' ');
    expect(result.label, 'No result found');
    expect(result.description, 'Try different names.');
  });

  test('a count of one leaves sister', () {
    final result = Flames.calculate('AA', 'A');
    expect(result.uniqueCount, 1);
    expect(result.letter, 'S');
    expect(result.label, 'SISTER');
  });

  test('sample names resolve to affection and skip punctuation', () {
    final result = Flames.calculate('Nayanthara!', '  Vignesh ');
    expect(result.label, 'AFFECTION');
    expect(result.letter, 'A');
    expect(result.herName, 'Nayanthara!');
    expect(result.hisName, 'Vignesh');
  });

  test('unicode letters are counted', () {
    final result = Flames.calculate('José', 'Jose');
    expect(result.uniqueCount, 2);
    expect(result.label, 'ENEMY');
  });
}
