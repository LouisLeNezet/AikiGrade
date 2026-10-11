import 'package:flutter/material.dart';

class ValueSelectionWidget<T> extends StatelessWidget {
  final T selectedValue;
  final ValueChanged<T> onValueChanged;
  final Map<String, T> valuesMap;
  final String hintText;
  final String titleText;
  final double width;

  const ValueSelectionWidget({
    super.key,
    required this.selectedValue,
    required this.onValueChanged,
    required this.valuesMap,
    required this.hintText,
    required this.titleText,
    this.width = 300.0,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          titleText,
          style: Theme.of(context).textTheme.headlineSmall,
          textAlign: TextAlign.center,
        ),

        SizedBox(
          width: width,
          child: DropdownButton<T>(
            value: selectedValue,
            isExpanded: true,
            alignment: Alignment.center,

            onChanged: (T? newValue) {
              if (newValue != null) {
                onValueChanged(newValue);
              }
            },

            hint: Text(hintText),

            items: valuesMap.entries.map((entry) {
              return DropdownMenuItem<T>(
                value: entry.value,
                child: Center(child: Text(entry.key)),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }
}
