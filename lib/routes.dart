import 'package:flutter/material.dart';
import 'package:aikigrade/functions/technique_class.dart';

// Start & Main Menu
import 'screens/start_menu/start_menu_screen.dart';
import 'screens/main_menu/main_menu_screen.dart';

// Exam Flow
import 'screens/exam/exam_menu_screen.dart';
import 'screens/exam/countdown_screen.dart';
import 'screens/exam/evaluation_screen.dart';

// Learn Section
import 'screens/learn/learn_menu_screen.dart';
import 'screens/learn/technique_detail_screen.dart';
import 'screens/learn/vocabulary_screen.dart';

// Progression Section
import 'screens/progression/progression_list_screen.dart';
import 'screens/progression/progression_detail_screen.dart';

// Config
import 'screens/config/config_screen.dart';

// More Info Section
import 'screens/info/more_infos_screen.dart';

class AppRoutes {
  static const start = '/';
  static const mainMenu = '/main-menu';

  // Exam
  static const examMenu = '/exam/menu';
  static const countdown = '/exam/countdown';
  static const evaluation = '/exam/evaluation';

  // learn
  static const learnMenu = '/learn/menu';
  static const techniqueFilter = '/learn/technique-filter';
  static const techniqueDetail = '/learn/technique-detail';
  static const vocabulary = '/learn/vocabulary';

  // Progression
  static const progressionList = '/progression/list';
  static const progressionDetail = '/progression/detail';

  // Config
  static const config = '/config';

  // More Infos
  static const moreInfos = '/info';
}

final Map<String, WidgetBuilder> appRoutes = {
  AppRoutes.start: (context) => const StartMenuScreen(),
  AppRoutes.mainMenu: (context) => const MainMenuScreen(),

  // Exam
  AppRoutes.examMenu: (context) => const ExamMenuScreen(),
  AppRoutes.countdown: (context) {
    final args = ModalRoute.of(context)?.settings.arguments as Map?;
    if (args == null) {
      return const Center(child: Text("Error: No arguments passed!"));
    }
    final fileName = args['fileName'] as String?;
    if (fileName == null || fileName.isEmpty) {
      return const Center(child: Text("Error: Invalid exam file!"));
    }
    return CountdownScreen(
      fileName: fileName,
    );
  },
  AppRoutes.evaluation: (context) {
    final args = ModalRoute.of(context)!.settings.arguments as Map;
    final fileName = args['fileName'] as String? ?? '';
    final index = args['index'] as int? ?? 0;
    return EvaluationScreen(
      fileName: fileName,
      index: index,
    );
  },
  // Learn
  AppRoutes.learnMenu: (context) => const LearnMenuScreen(fileName: "learningJson",),
  AppRoutes.techniqueDetail: (context) {
    final args = ModalRoute.of(context)!.settings.arguments as Map;
    // Convert the map to a Technique object
    final techniqueMap = args;
    final technique = Technique(
      waza: techniqueMap['waza'] ?? '',
      attack: techniqueMap['attack'] ?? '',
      technique: techniqueMap['technique'] ?? '',
      form: techniqueMap['form'] ?? '',
      grade: techniqueMap['techniqueGrade'] ?? techniqueMap['grade'] ?? '',
      links: List<String>.from(techniqueMap['links'] ?? []),
      markdown: techniqueMap['markdown'] ?? '',
      progression: List<Map<String, dynamic>>.from(techniqueMap['progression'] ?? []),
    );
    return TechniqueDetailScreen(technique: technique);
  },
  AppRoutes.vocabulary: (context) => const VocabularyScreen(),

  // Progression
  AppRoutes.progressionList: (context) => const ProgressionListScreen(),
  AppRoutes.progressionDetail: (context) {
    final args = ModalRoute.of(context)!.settings.arguments as Map;
    final fileName = args['fileName'] as String? ?? '';
    return ProgressionDetailScreen(fileName: fileName);
  },

  // Config
  AppRoutes.config: (context) => const ConfigScreen(),

  // More Infos
  AppRoutes.moreInfos: (context) => const MoreInfoScreen(),
};
