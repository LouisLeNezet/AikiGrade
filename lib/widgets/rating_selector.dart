import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'rating_style.dart';

class RatingSelector extends StatelessWidget {
  final int rating;
  final ValueChanged<int> onChanged;

  const RatingSelector({
    super.key,
    required this.rating,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return RatingBar.builder(
      initialRating: rating.toDouble(),
      minRating: 1,
      itemCount: 5,
      unratedColor: Colors.grey,
      itemPadding: const EdgeInsets.symmetric(horizontal: 4),
      itemBuilder: (context, index) {
        final ratingValue = index + 1;
        return Icon(
          RatingStyle.iconFor(ratingValue),
          color: RatingStyle.colorFor(ratingValue),
        );
      },
      onRatingUpdate: (value) {
        onChanged(value.round());
      },
    );
  }
}
