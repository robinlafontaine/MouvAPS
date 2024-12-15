import 'package:flutter/material.dart';

class RatingWidget extends StatelessWidget {
  final int filledSteps;
  final int totalSteps;

  const RatingWidget({
    super.key,
    required this.filledSteps,
    this.totalSteps = 5, // Total number of steps
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 90,
          height: 90,
          decoration: const BoxDecoration(
            color: Colors.blue,
            shape: BoxShape.circle,
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SizedBox(height: 5),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(totalSteps, (index) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 2.0),
                    child: Icon(
                      index < filledSteps
                          ? Icons.square
                          : Icons.crop_square, // Filled or empty step
                      size: 10,
                      color: Colors.white,
                    ),
                  );
                }),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
