import 'package:flutter/material.dart';
import 'package:mouvaps/utils/constants.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

class BadgeText extends StatelessWidget {
  final String content;
  final Color _textColor;
  const BadgeText(
      {
        super.key,
        required this.content,
        Color? color,
      }
      ) : _textColor = color ?? textColor;

  @override
  Widget build(BuildContext context) {
    return Text(
      content,
      style: TextStyle(
        fontFamily: fontFamily,
        fontSize: badgeFontSize,
        fontVariations:const [
          FontVariation(
              'wght', badgeFontWeight
          )
        ],
        color: _textColor,
      ),
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

class H3 extends StatelessWidget {
  final String content;
  const H3(
      {super.key, required this.content}
      );

  @override
  Widget build(BuildContext context) {
    return Text(
      content,
      style: ShadTheme.of(context).textTheme.h3
    );
  }
}

class H4 extends StatelessWidget {
  final String content;
  const H4(
      {super.key, required this.content}
      );

  @override
  Widget build(BuildContext context) {
    return Text(
      content,
      style: ShadTheme.of(context).textTheme.h4
    );
  }
}

class SubTitle extends StatelessWidget {
  final String content;
  const SubTitle(
      {super.key, required this.content}
      );

  @override
  Widget build(BuildContext context) {
    return Text(
      content,
      style: const TextStyle(
        fontFamily: fontFamily,
        fontSize: subtitleFontSize,
        fontVariations:[
          FontVariation(
              'wght', subtitleFontWeight
          )
        ],
        color: textColor,
      ),
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
    return Text(
      content,
      style: ShadTheme.of(context).textTheme.p
    );
  }
}

extension StringExtension on String {
  String capitalize() {
    return "${this[0].toUpperCase()}${substring(1).toLowerCase()}";
  }
}

