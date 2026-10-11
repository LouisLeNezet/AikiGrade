import 'dart:async';
import 'package:flutter/widgets.dart';
import '../../functions/config_service.dart';
import '../../functions/technique_class.dart';
import '../../functions/technique_load_files.dart';
import '../../functions/learn_json.dart';

int orderCompare(String a, String b, Map<String, int> orderMap) {
  if (a == b) return 0;
  if (a.isEmpty) return 1; // empty string is always last
  if (b.isEmpty) return -1; // empty string is always last

  // Throw error if both are not in orderMap
  if (!orderMap.containsKey(a)) {
    throw Exception('Key "$a" not found in orderMap');
  }
  if (!orderMap.containsKey(b)) {
    throw Exception('Key "$b" not found in orderMap');
  }
  return (orderMap[a] ?? 999).compareTo(orderMap[b] ?? 999);
}

int compareNullableDate(DateTime? a, DateTime? b) {
  // null = never trained = highest priority
  if (a == null && b == null) return 0;
  if (a == null) return -1;
  if (b == null) return 1;

  // oldest first
  return a.compareTo(b);
}

int compareNullableRating(int? a, int? b) {
  // null = never rated = highest priority
  if (a == null && b == null) return 0;
  if (a == null) return -1;
  if (b == null) return 1;

  // lower rating first
  return a.compareTo(b);
}

Future<List<Technique>> orderTechniques({
  required List<Technique> lstTechniques,
}) async {
  final orders = await loadOrderTechnique('assets/csv/techniques_ordering.csv');
  final attackOrder = orders['Attack']!;
  final wazaOrder = orders['Waza']!;
  final techniqueOrder = orders['Technique']!;
  final formOrder = orders['Form']!;

  // Sort by waza (first column) in ascending order
  lstTechniques.sort((a, b) {
    final cmpWaza = orderCompare(a.waza, b.waza, wazaOrder);
    if (cmpWaza != 0) return cmpWaza;

    final cmpAttack = orderCompare(a.attack, b.attack, attackOrder);
    if (cmpAttack != 0) return cmpAttack;

    final cmpTechnique = orderCompare(a.technique, b.technique, techniqueOrder);
    if (cmpTechnique != 0) return cmpTechnique;

    return orderCompare(a.form, b.form, formOrder);
  });

  return lstTechniques;
}

Future<List<Technique>> filterTechniquesGrades(
  List<Technique> techniques,
  String grade,
) async {
  const grades = ['5 Kyu', '4 Kyu', '3 Kyu', '2 Kyu', '1 Kyu'];
  final maxIdx = grades.indexOf(grade);
  if (maxIdx < 0) throw 'Unknown grade $grade';

  return techniques.where((t) => grades.indexOf(t.grade) <= maxIdx).toList();
}

List<Technique> pickByLastProgressionDate(List<Technique> bucket, int count) {
  final sorted = [...bucket];

  sorted.sort(
    (a, b) => compareNullableDate(a.lastProgressionDate, b.lastProgressionDate),
  );

  return sorted.take(count).toList();
}

List<Technique> pickByLastProgressionRating(List<Technique> bucket, int count) {
  final sorted = [...bucket];

  sorted.sort(
    (a, b) =>
        compareNullableRating(a.lastProgressionRating, b.lastProgressionRating),
  );

  return sorted.take(count).toList();
}

List<Technique> pickNewItems(
  List<Technique> bucket,
  int count,
  String byKey,
  Set<Object> alreadySeen,
) {
  final newOnes = bucket
      .where((t) => !alreadySeen.contains(t.getValue(byKey)))
      .toList();

  final oldOnes = bucket
      .where((t) => alreadySeen.contains(t.getValue(byKey)))
      .toList();

  return [
    ...newOnes.take(count),
    ...oldOnes.take((count - newOnes.length).clamp(0, count)),
  ].take(count).toList();
}

List<Technique> pick(
  List<Technique> bucket,
  int count,
  String byKey,
  Set<Object> alreadySeen,
) {
  switch (byKey) {
    case 'lastProgressionDate':
      return pickByLastProgressionDate(bucket, count);

    case 'lastProgressionRating':
      return pickByLastProgressionRating(bucket, count);

    default:
      return pickNewItems(bucket, count, byKey, alreadySeen);
  }
}

/// [path] to techniques CSV, [grade] current,
/// returns a subset to fit time-constraints, split 60/30/10 over grades,
/// and per-waza time quotas.
Future<List<Technique>> subsetTechniques({
  required String grade,
  required String gradeTimeCsvPath,
  List<double> ratios = const [0.6, 0.3, 0.1],
}) async {
  // 1) load everything
  final allTech = await getLearnTechniques(learnFile: 'learningJson');
  final allTechGrade = await filterTechniquesGrades(allTech, grade);
  final gradeTimes = await loadGradeTimes(gradeTimeCsvPath);

  // 2) get current and two previous grades
  const grades = ['5 Kyu', '4 Kyu', '3 Kyu', '2 Kyu', '1 Kyu'];
  final gi = grades.indexOf(grade);
  final poolGrades = <String>[];
  if (gi >= 0) poolGrades.add(grades[gi]);
  if (gi - 1 >= 0) poolGrades.add(grades[gi - 1]);
  if (gi - 2 >= 0) poolGrades.add(grades[gi - 2]);

  // 3) split 60/30/10
  final gradeBuckets = <String, List<Technique>>{};
  for (var i = 0; i < poolGrades.length; i++) {
    gradeBuckets[poolGrades[i]] = allTechGrade
        .where((t) => t.grade == poolGrades[i])
        .toList();
  }

  // 4) per-waza time, then #techniques by timePerTechnique
  final timePerTechnique = ConfigService.getConfig('timePerTechnique') ?? 60;
  debugPrint('Time per technique: $timePerTechnique');
  final wazas = gradeTimes[grade]?.keys.toList() ?? [];
  debugPrint('Wazas: $wazas');
  if (timePerTechnique == 0) {
    throw Exception('timePerTechnique cannot be 0');
  }
  final perPosSeconds = gradeTimes[grade]!;
  debugPrint('Per waza seconds: $perPosSeconds');
  final perPosSlots = <String, int>{
    for (var w in wazas) w: (perPosSeconds[w] ?? 0) ~/ timePerTechnique,
  };
  debugPrint('Per waza slots: $perPosSlots');

  // 5) prioritize by key
  final byKey = (ConfigService.getConfig('prioritizeBy') ?? 'attack');
  debugPrint('Prioritize by: $byKey');

  // 6) already seen for each key
  final seenKeys = <Object>{};

  // 7) assemble subset
  final subset = <Technique>[];
  for (var waza in wazas) {
    final slots = perPosSlots[waza] ?? 0;
    if (slots <= 0) continue;

    // gather all by waza, then split by grade-ratio
    final posTech = allTechGrade.where((t) => t.waza == waza).toList();

    for (var i = 0; i < ratios.length; i++) {
      if (i >= poolGrades.length) break;
      final g = poolGrades[i];
      final bucket = posTech.where((t) => t.grade == g).toList();
      final takeCount = (slots * ratios[i]).round();
      final picked = pick(bucket, takeCount, byKey, seenKeys);
      subset.addAll(picked);
      seenKeys.addAll(picked.map((t) => t.getValue(byKey)).whereType<Object>());
    }

    // if rounding gap, fill from current grade
    if (subset.where((t) => t.waza == waza).length < slots) {
      final remaining = slots - subset.where((t) => t.waza == waza).length;
      final currBucket = posTech.where((t) => t.grade == grade).toList();
      subset.addAll(pick(currBucket, remaining, byKey, seenKeys));
    }
  }

  return orderTechniques(lstTechniques: subset);
}
