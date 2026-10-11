/// A single technique record.
class Technique {
  final String waza;
  final String attack;
  final String technique;
  final String form;
  final String grade;
  final List<String> links;
  final String markdown;
  final List<Map<String, dynamic>> progression;

  Technique({
    required this.waza,
    required this.attack,
    required this.technique,
    required this.form,
    required this.grade,
    this.links = const [],
    this.markdown = '',
    this.progression = const [],
  });

  /// -------------------------
  /// Computed progression data
  /// -------------------------

  Map<String, dynamic>? get lastProgression =>
      progression.isNotEmpty ? progression.last : null;

  DateTime? get lastProgressionDate {
    final rawDate = lastProgression?['date'];
    if (rawDate == null) {
      return null;
    }
    if (rawDate is DateTime) {
      return rawDate;
    }
    return DateTime.tryParse(rawDate.toString());
  }

  int get lastProgressionRating {
    final rawRating = lastProgression?['rating'];
    if (rawRating == null) {
      return 0;
    }
    if (rawRating is int) {
      return rawRating;
    }
    return int.tryParse(rawRating.toString()) ?? 0;
  }

  bool get neverTested => progression.isEmpty;

  dynamic operator [](String key) {
    switch (key) {
      case 'waza':
        return waza;
      case 'attack':
        return attack;
      case 'technique':
        return technique;
      case 'form':
        return form;
      case 'grade':
        return grade;
      case 'links':
        return links;
      case 'markdown':
        return markdown;
      case 'progression':
        return progression;
      case 'lastProgressionDate':
        return lastProgressionDate;
      case 'lastProgressionRating':
        return lastProgressionRating;
      case 'neverTested':
        return neverTested;
      default:
        throw ArgumentError('Invalid key: $key');
    }
  }

  dynamic getValue(String key) {
    switch (key.toLowerCase()) {
      case 'waza':
        return waza;
      case 'attack':
        return attack;
      case 'technique':
        return technique;
      case 'form':
        return form;
      case 'grade':
        return grade;
      case 'lastprogressiondate':
        return lastProgressionDate;
      case 'lastprogressionrating':
        return lastProgressionRating;
      case 'nevertested':
        return neverTested;
      default:
        throw ArgumentError('Invalid String key: $key');
    }
  }

  // Override toString for custom printing
  @override
  String toString() {
    return '''
Technique(
  waza: $waza,
  attack: $attack,
  technique: $technique,
  form: $form,
  grade: $grade,
  links: $links,
  markdown: $markdown,
  progression: $progression
)''';
  }
}
