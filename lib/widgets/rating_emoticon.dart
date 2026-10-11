import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import '../../widgets/rating_style.dart';

class RatingEmoticon extends StatelessWidget {
  final int rating;
  final bool showValue;
  final double iconSize;

  const RatingEmoticon({
    super.key,
    required this.rating,
    this.showValue = true,
    this.iconSize = 20,
  });

  @override
  Widget build(BuildContext context) {
    final icon = RatingStyle.iconFor(rating);
    final color = RatingStyle.colorFor(rating);

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: color, size: iconSize),
        if (showValue) ...[const SizedBox(width: 6), Text('$rating')],
      ],
    );
  }
}

class RatingSelector extends StatelessWidget {
  final double rating;
  final ValueChanged<double> onChanged;

  const RatingSelector({
    super.key,
    required this.rating,
    required this.onChanged,
  });

  Widget _iconForIndex(int index) {
    switch (index) {
      case 0:
        return const Icon(Icons.sentiment_very_dissatisfied, color: Colors.red);
      case 1:
        return const Icon(
          Icons.sentiment_dissatisfied,
          color: Colors.redAccent,
        );
      case 2:
        return const Icon(Icons.sentiment_neutral, color: Colors.amber);
      case 3:
        return const Icon(Icons.sentiment_satisfied, color: Colors.lightGreen);
      case 4:
        return const Icon(Icons.sentiment_very_satisfied, color: Colors.green);
      default:
        return const Icon(Icons.sentiment_neutral, color: Colors.grey);
    }
  }

  @override
  Widget build(BuildContext context) {
    return RatingBar.builder(
      initialRating: 0,
      minRating: 1,
      itemCount: 5,
      unratedColor: Colors.grey,
      itemPadding: const EdgeInsets.symmetric(horizontal: 4),
      itemBuilder: (context, index) => _iconForIndex(index),
      onRatingUpdate: onChanged,
    );
  }
}
