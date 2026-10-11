import 'package:flutter_test/flutter_test.dart';
import 'package:aikigrade/functions/technique_filter.dart';
import 'package:aikigrade/functions/technique_class.dart';

void main() {
  group('Technique.compareNullableDate', () {
    test('null dates are prioritized first', () {
      expect(compareNullableDate(null, DateTime(2024, 1, 1)), lessThan(0));

      expect(compareNullableDate(DateTime(2024, 1, 1), null), greaterThan(0));
    });

    test('two null dates are equal', () {
      expect(compareNullableDate(null, null), equals(0));
    });

    test('older dates are prioritized first', () {
      final oldDate = DateTime(2023, 1, 1);
      final newDate = DateTime(2024, 1, 1);

      expect(compareNullableDate(oldDate, newDate), lessThan(0));

      expect(compareNullableDate(newDate, oldDate), greaterThan(0));
    });
  });

  group('Technique.compareNullableRating', () {
    test('lower rating is prioritized first', () {
      expect(compareNullableRating(1, 5), lessThan(0));

      expect(compareNullableRating(5, 1), greaterThan(0));
    });

    test('null ratings default to 0', () {
      expect(compareNullableRating(null, 5), lessThan(0));

      expect(compareNullableRating(5, null), greaterThan(0));

      expect(compareNullableRating(0, null), greaterThan(0));
    });

    test('equal ratings return 0', () {
      expect(compareNullableRating(3, 3), equals(0));
    });
  });

  group('pickByLastProgressionDate', () {
    test('prioritizes never tested techniques first', () {
      final neverTested = Technique(
        waza: 'Tachi Waza',
        attack: 'Shomen Uchi',
        technique: 'Ikkyo',
        form: '',
        grade: '5 Kyu',
      );

      final tested = Technique(
        waza: 'Tachi Waza',
        attack: 'Katate Dori',
        technique: 'Nikyo',
        form: '',
        grade: '5 Kyu',
        progression: [
          {'date': '2024-01-01', 'rating': 3},
        ],
      );

      final result = pickByLastProgressionDate([tested, neverTested], 1);

      expect(result.first, equals(neverTested));
    });

    test('prioritizes oldest progression date first', () {
      final oldTech = Technique(
        waza: 'Tachi Waza',
        attack: 'A',
        technique: 'Old',
        form: '',
        grade: '5 Kyu',
        progression: [
          {'date': '2023-01-01', 'rating': 3},
        ],
      );

      final newTech = Technique(
        waza: 'Tachi Waza',
        attack: 'B',
        technique: 'New',
        form: '',
        grade: '5 Kyu',
        progression: [
          {'date': '2024-01-01', 'rating': 3},
        ],
      );

      final result = pickByLastProgressionDate([newTech, oldTech], 1);

      expect(result.first, equals(oldTech));
    });
  });

  group('pickByLastProgressionRating', () {
    test('prioritizes lowest rating first', () {
      final lowRating = Technique(
        waza: 'Tachi Waza',
        attack: 'A',
        technique: 'Low',
        form: '',
        grade: '5 Kyu',
        progression: [
          {'date': '2024-01-01', 'rating': 1},
        ],
      );

      final highRating = Technique(
        waza: 'Tachi Waza',
        attack: 'B',
        technique: 'High',
        form: '',
        grade: '5 Kyu',
        progression: [
          {'date': '2024-01-01', 'rating': 5},
        ],
      );

      final result = pickByLastProgressionRating([highRating, lowRating], 1);

      expect(result.first, equals(lowRating));
    });

    test('never tested techniques default to rating 0', () {
      final neverTested = Technique(
        waza: 'Tachi Waza',
        attack: 'A',
        technique: 'Never',
        form: '',
        grade: '5 Kyu',
      );

      final rated = Technique(
        waza: 'Tachi Waza',
        attack: 'B',
        technique: 'Rated',
        form: '',
        grade: '5 Kyu',
        progression: [
          {'date': '2024-01-01', 'rating': 3},
        ],
      );

      final result = pickByLastProgressionRating([rated, neverTested], 1);

      expect(result.first, equals(neverTested));
    });
  });

  group('pickNewItems', () {
    test('prioritizes unseen attack values', () {
      final tech1 = Technique(
        waza: 'Tachi Waza',
        attack: 'Shomen Uchi',
        technique: 'Ikkyo',
        form: '',
        grade: '5 Kyu',
      );

      final tech2 = Technique(
        waza: 'Tachi Waza',
        attack: 'Katate Dori',
        technique: 'Nikyo',
        form: '',
        grade: '5 Kyu',
      );

      final result = pickNewItems([tech1, tech2], 1, 'attack', {'Shomen Uchi'});

      expect(result.first.attack, equals('Katate Dori'));
    });

    test('fills remaining slots with already seen values', () {
      final tech1 = Technique(
        waza: 'Tachi Waza',
        attack: 'Shomen Uchi',
        technique: 'Ikkyo',
        form: '',
        grade: '5 Kyu',
      );

      final result = pickNewItems([tech1], 1, 'attack', {'Shomen Uchi'});

      expect(result.length, equals(1));
      expect(result.first, equals(tech1));
    });
  });

  group('pick', () {
    test('uses date prioritization when byKey is lastProgressionDate', () {
      final neverTested = Technique(
        waza: 'Tachi Waza',
        attack: 'A',
        technique: 'Never',
        form: '',
        grade: '5 Kyu',
      );

      final tested = Technique(
        waza: 'Tachi Waza',
        attack: 'B',
        technique: 'Tested',
        form: '',
        grade: '5 Kyu',
        progression: [
          {'date': '2024-01-01', 'rating': 3},
        ],
      );

      final result = pick([tested, neverTested], 1, 'lastProgressionDate', {});

      expect(result.first, equals(neverTested));
    });

    test('uses rating prioritization when byKey is lastProgressionRating', () {
      final low = Technique(
        waza: 'Tachi Waza',
        attack: 'A',
        technique: 'Low',
        form: '',
        grade: '5 Kyu',
        progression: [
          {'date': '2024-01-01', 'rating': 1},
        ],
      );

      final high = Technique(
        waza: 'Tachi Waza',
        attack: 'B',
        technique: 'High',
        form: '',
        grade: '5 Kyu',
        progression: [
          {'date': '2024-01-01', 'rating': 5},
        ],
      );

      final result = pick([high, low], 1, 'lastProgressionRating', {});

      expect(result.first, equals(low));
    });

    test('uses new item prioritization for standard keys', () {
      final tech1 = Technique(
        waza: 'Tachi Waza',
        attack: 'Seen',
        technique: 'Ikkyo',
        form: '',
        grade: '5 Kyu',
      );

      final tech2 = Technique(
        waza: 'Tachi Waza',
        attack: 'New',
        technique: 'Nikyo',
        form: '',
        grade: '5 Kyu',
      );

      final result = pick([tech1, tech2], 1, 'attack', {'Seen'});

      expect(result.first.attack, equals('New'));
    });
  });
}
