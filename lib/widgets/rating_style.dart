import 'package:flutter/material.dart';

class RatingStyle {
  static IconData iconFor(int rating) {
    switch (rating) {
      case 0:
        return Icons.sentiment_neutral;
      case 1:
        return Icons.sentiment_very_dissatisfied;
      case 2:
        return Icons.sentiment_dissatisfied;
      case 3:
        return Icons.sentiment_neutral;
      case 4:
        return Icons.sentiment_satisfied;
      case 5:
        return Icons.sentiment_very_satisfied;
      default:
        throw ArgumentError('Invalid rating: $rating');
    }
  }

  static Color colorFor(int rating) {
    switch (rating) {
      case 0:
        return Colors.grey;
      case 1:
        return Colors.red;
      case 2:
        return Colors.redAccent;
      case 3:
        return Colors.amber;
      case 4:
        return Colors.lightGreen;
      case 5:
        return Colors.green;
      default:
        throw ArgumentError('Invalid rating: $rating');
    }
  }
}
