import 'package:flutter/material.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

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
      style: ShadTheme.of(context).textTheme.h1);
  }
}

class H2 extends StatelessWidget {
  final String content;
  const H2(
      {super.key, required this.content}
      );

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Text(
          content,
          style: ShadTheme.of(context).textTheme.h2),
    );
  }
}

class P extends StatelessWidget {
  final String content;
  const P(
      {super.key, required this.content}
      );

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 10.0, right: 10.0, bottom: 8.0),
      child: Text(
          content,
          textAlign: TextAlign.justify,
          style: ShadTheme.of(context).textTheme.p),
    );
  }
}

extension StringExtension on String {
  String capitalize() {
    return "${this[0].toUpperCase()}${substring(1).toLowerCase()}";
  }
}

