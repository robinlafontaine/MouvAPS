import 'package:flutter/material.dart';
import 'package:mouvaps/utils/constants.dart';

class CustomBadge extends StatelessWidget {
  final String text;
  final Color backgroundColor;
  final Color textColor;

  const CustomBadge({super.key,
    required this.text,
    required this.backgroundColor,
    required this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    return Badge(
        label: Text(
            text,
            style: const TextStyle(fontSize: badgeFontSize),
        ),
        backgroundColor: backgroundColor,
        textColor: textColor,
        padding: const EdgeInsets.only(left: 8, right: 8, top: 2, bottom: 2)
    );
  }
}