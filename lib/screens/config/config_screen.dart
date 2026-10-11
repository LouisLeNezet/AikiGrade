import 'package:flutter/material.dart';
import '../../functions/config_service.dart';
import '../../functions/utils.dart';
import '../../constants/colors.dart';
import '../../widgets/text_input.dart';
import '../../widgets/drop_down_selection.dart';
import '../../widgets/scaffold_with_wide_bottom_panel.dart';
import '../../widgets/layouts/page_layout.dart';
import '../../widgets/confirm_dialog.dart';

class ConfigScreen extends StatefulWidget {
  const ConfigScreen({super.key});

  @override
  ConfigScreenState createState() => ConfigScreenState();
}

class ConfigFormState {
  String examDefaultName;
  int timePerTechnique;
  String prioritizeBy;
  int numberOfTechniquePerAttack;

  ConfigFormState({
    required this.examDefaultName,
    required this.timePerTechnique,
    required this.prioritizeBy,
    required this.numberOfTechniquePerAttack,
  });

  factory ConfigFormState.fromConfig(Map<String, dynamic> config) {
    return ConfigFormState(
      examDefaultName: config['examDefaultName'] ?? 'My Exam',
      timePerTechnique: config['timePerTechnique'] ?? 60,
      prioritizeBy: config['prioritizeBy'] ?? 'attack',
      numberOfTechniquePerAttack: config['numberOfTechniquePerAttack'] ?? 2,
    );
  }
}

class ConfigScreenState extends State<ConfigScreen> {
  bool _loaded = false;

  late ConfigFormState form;

  @override
  void initState() {
    super.initState();
    _loadConfig();
  }

  Future<void> _loadConfig() async {
    await ConfigService.loadConfig();

    final config = {
      'examDefaultName': ConfigService.getConfig('examDefaultName'),
      'timePerTechnique': ConfigService.getConfig('timePerTechnique'),
      'prioritizeBy': ConfigService.getConfig('prioritizeBy'),
      'numberOfTechniquePerAttack': ConfigService.getConfig(
        'numberOfTechniquePerAttack',
      ),
    };

    setState(() {
      form = ConfigFormState.fromConfig(config);
      _loaded = true;
    });
  }

  void _saveConfig() {
    final finalExamName = form.examDefaultName.trim().isEmpty
        ? 'My Exam'
        : form.examDefaultName.trim();

    ConfigService.setConfig('examDefaultName', finalExamName);
    ConfigService.setConfig('timePerTechnique', form.timePerTechnique);
    ConfigService.setConfig('prioritizeBy', form.prioritizeBy);
    ConfigService.setConfig(
      'numberOfTechniquePerAttack',
      form.numberOfTechniquePerAttack,
    );

    ConfigService.saveConfig();

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Configuration saved successfully!')),
    );

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    if (!_loaded) {
      return const Center(child: CircularProgressIndicator());
    }

    return ScaffoldWithWideBottomPanel(
      body: PageLayout(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextInput(
              initialValue: form.examDefaultName,
              hintText: "Enter Exam Name",
              title: "Exam Name",
              onChanged: (value) {
                form.examDefaultName = value;
              },
            ),

            const SizedBox(height: 20),

            Center(
              child: ValueSelectionWidget<int>(
                selectedValue: form.timePerTechnique,
                onValueChanged: (v) {
                  setState(() {
                    form.timePerTechnique = v;
                  });
                },
                valuesMap: {
                  "10": 10,
                  "15": 15,
                  "20": 20,
                  "25": 25,
                  "30": 30,
                  "40": 40,
                  "60": 60,
                  "90": 90,
                  "120": 120,
                  "180": 180,
                },
                hintText: "Select Time per technique",
                titleText: "Time per Technique",
              ),
            ),

            const SizedBox(height: 20),

            Center(
              child: ValueSelectionWidget<String>(
                selectedValue: form.prioritizeBy,
                onValueChanged: (v) {
                  setState(() {
                    form.prioritizeBy = v;
                  });
                },
                valuesMap: {
                  "Attack": "attack",
                  "Technique": "technique",
                  "Last Progression Date": "lastProgressionDate",
                  "Last Progression Rating": "lastProgressionRating",
                },
                hintText: "Prioritize by",
                titleText: "Prioritize By",
              ),
            ),

            const SizedBox(height: 20),

            Center(
              child: ValueSelectionWidget<int>(
                selectedValue: form.numberOfTechniquePerAttack,
                onValueChanged: (v) {
                  setState(() {
                    form.numberOfTechniquePerAttack = v;
                  });
                },
                valuesMap: {"1": 1, "2": 2, "3": 3, "4": 4, "5": 5},
                hintText: "Max techniques per attack",
                titleText: "Max Number of Technique per Attack",
              ),
            ),

            const SizedBox(height: 20),

            ElevatedButton(
              onPressed: _saveConfig,
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 50),
                backgroundColor: AppColors.buttonColor,
                foregroundColor: AppColors.textColor,
              ),
              child: const Text('Save Configuration'),
            ),

            const SizedBox(height: 20),

            ElevatedButton(
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 50),
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),
              onPressed: () async {
                final confirm = await showConfirmDialog(
                  context: context,
                  title: 'Reset data',
                  content: 'This will permanently delete all your local data.',
                  confirmText: 'Delete',
                  confirmColor: Colors.red,
                );

                if (confirm == true) {
                  await resetData();
                }
              },
              child: const Text('Reset local data'),
            ),
          ],
        ),
      ),
    );
  }
}
