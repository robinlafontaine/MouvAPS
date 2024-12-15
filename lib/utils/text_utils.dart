import 'package:flutter/material.dart';

class MediumText extends StatelessWidget {
  final String content;
  const MediumText(
      {super.key, required this.content}
      );

  @override
  Widget build(BuildContext context) {
    return Text(
      content,
      style: const TextStyle(fontWeight: FontWeight.w500),
    );
  }
}

class H1 extends StatelessWidget {
  final String content;
  const H1(
      {super.key, required this.content}
      );

  @override
  Widget build(BuildContext context) {
    return Text(
      content,
      style: const TextStyle(
        fontWeight: FontWeight.w600,
        fontSize: 32,
        color: Color.fromRGBO(81, 144, 195, 1),
      ),
    );
  }
}