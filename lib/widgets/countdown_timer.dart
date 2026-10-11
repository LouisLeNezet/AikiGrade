import 'dart:async';
import 'package:aikigrade/constants/colors.dart';
import 'package:flutter/material.dart';

class CountdownTimer extends StatefulWidget {
  final int duration; // The countdown duration in seconds
  final VoidCallback onFinish; // Callback function when the countdown finishes

  const CountdownTimer({
    super.key,
    required this.duration,
    required this.onFinish,
  });

  @override
  State<CountdownTimer> createState() => _CountdownTimerState();
}

class _CountdownTimerState extends State<CountdownTimer> with SingleTickerProviderStateMixin {
  late int countdown; // The countdown value (in seconds)
  late double progress; // Circle progress (fraction of time elapsed)
  late AnimationController _animationController;
  Timer? timer;

  @override
  void initState() {
    super.initState();
    countdown = widget.duration;
    progress = 1.0; // Start with the full circle (100%)
    
    // Initialize the AnimationController
    _animationController = AnimationController(
      vsync: this,
      duration: Duration(seconds: widget.duration),
    );

    // Start the countdown and animation
    startCountdown();
  }

  // Start the countdown and update the timer every second
  void startCountdown() {
    // Start the countdown timer
    timer = Timer.periodic(const Duration(seconds: 1), (Timer t) {
      setState(() {
        if (countdown > 0) {
          countdown--;
        }

        // Update the progress of the animation based on the countdown
        progress = (widget.duration - countdown + 1) / widget.duration;
        _animationController.animateTo(progress);

        // When countdown reaches 0, stop the timer and animation
        if (countdown == 0) {
          Future.delayed(const Duration(milliseconds: 500), () {
            t.cancel(); // Stop the timer
            _animationController.stop(); // Stop the animation after the delay
            widget.onFinish(); // Call the callback function when finished
          });
        }
      });
    });

    // Start the animation from the beginning
    _animationController.forward(from: 0.0);
  }

  @override
  void dispose() {
    timer?.cancel();
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Larger circle using SizedBox
          SizedBox(
            height: 200, // Circle size
            width: 200,  // Circle size
            child: AnimatedBuilder(
              animation: _animationController,
              builder: (context, child) {
                return CircularProgressIndicator(
                  value: _animationController.value, // Circle decreases as the timer goes down
                  strokeWidth: 12, // Stroke width of the circle
                  valueColor: AlwaysStoppedAnimation<Color>(AppColors.accentColor), // Circle color
                  backgroundColor: AppColors.backgroundColor, // Background color
                );
              },
            ),
          ),
          // Display the remaining time in seconds (centered)
          Text(
            "$countdown",
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  fontSize: 80,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
          ),
        ],
      ),
    );
  }
}
