import 'package:flutter/material.dart';

class TextInput extends StatelessWidget {
  final void Function(String textValue) onChanged;
  final String hintText;
  final String title;
  final String initialValue;

  const TextInput({
    super.key,
    required this.onChanged,
    required this.hintText,
    required this.title,
    required this.initialValue, // Added this parameter to set default value
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: Theme.of(context).textTheme.headlineSmall),
        const SizedBox(height: 8),
        TextField(
          controller: TextEditingController(
            text: initialValue,
          ), // Set default value
          onChanged: onChanged,
          decoration: InputDecoration(
            hintText: hintText,
            border: const OutlineInputBorder(),
          ),
          textDirection: TextDirection.ltr,
        ),
      ],
    );
  }
}
