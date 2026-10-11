import 'package:flutter/material.dart';
import '../../constants/colors.dart';
import '../../routes.dart';
import '../../widgets/drop_down_selection.dart';
import '../../widgets/scaffold_with_wide_bottom_panel.dart';
import '../../widgets/layouts/page_layout.dart';
import '../../widgets/text_input.dart';
import '../../functions/exam_json.dart';
import '../../functions/config_service.dart';

class ExamMenuScreen extends StatefulWidget {
  const ExamMenuScreen({super.key});

  @override
  ExamMenuScreenState createState() => ExamMenuScreenState();
}

class ExamMenuScreenState extends State<ExamMenuScreen> {
  String selectedGrade = '5 Kyu';
  String examName = '';
  String examNameDefault = 'Loading...';

  final Map<String, String> gradesList = {
    '5 Kyu': '5 Kyu',
    '4 Kyu': '4 Kyu',
    '3 Kyu': '3 Kyu',
    '2 Kyu': '2 Kyu',
    '1 Kyu': '1 Kyu',
  };

  @override
  void initState() {
    super.initState();
    _loadConfig();
  }

  Future<void> _loadConfig() async {
    await ConfigService.loadConfig();
    setState(() {
      examNameDefault =
          ConfigService.getConfig('examDefaultName') ??
          'My Exam'; // Use the value from config or fallback to default
      examName = examNameDefault; // Set examName to the default value
    });
  }

  @override
  Widget build(BuildContext context) {
    return ScaffoldWithWideBottomPanel(
      body: PageLayout(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              "Let's Start Your Exam",
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: AppColors.textColor,
              ),
            ),

            const SizedBox(height: 50),

            // Get exam name from user
            TextInput(
              onChanged: (value) {
                examName = value;
              },
              hintText: "Enter Exam Name",
              title: "Exam Name",
              initialValue: examNameDefault,
            ),

            const SizedBox(height: 20),

            ValueSelectionWidget(
              selectedValue: selectedGrade,
              onValueChanged: (newGrade) {
                setState(() {
                  selectedGrade = newGrade;
                });
              },
              valuesMap: gradesList,
              hintText: "Select Grade",
              titleText: "Grade",
            ),

            const SizedBox(height: 50),

            // Start Button
            ElevatedButton(
              onPressed: () {
                _handleCreateExam();
              },
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 50), // Full width
                padding: const EdgeInsets.symmetric(vertical: 16),
                foregroundColor: AppColors.textColor, // Text color
                backgroundColor: AppColors.buttonColor, // Button color
              ),
              child: const Text(
                "Start Exam",
                style: TextStyle(fontSize: 18, color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _handleCreateExam() async {
    final fileName = await createExamJsonFile(
      grade: selectedGrade,
      examName: examName.isNotEmpty ? examName : examNameDefault,
    ).timeout(const Duration(seconds: 5));

    if (!mounted) return;

    Navigator.pushNamed(
      context,
      AppRoutes.countdown,
      arguments: {'fileName': fileName},
    );
  }
}
