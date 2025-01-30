import 'package:flutter/material.dart';
import 'package:shadcn_ui/shadcn_ui.dart';
import 'package:mouvaps/globals/globals.dart' as globals;

import 'package:mouvaps/utils/text_utils.dart';

class ProfileSwitch extends StatefulWidget {
  const ProfileSwitch({super.key});

  @override
  State<ProfileSwitch> createState() => _ProfileSwitchState();
}

class _ProfileSwitchState extends State<ProfileSwitch> {
  bool value = globals.isAdmin;

  void handleToggle(bool newValue) {
    setState(() => value = newValue);
    globals.isAdmin = newValue;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      child: ShadSwitch(
        value: value,
        onChanged: (v) => handleToggle(v),
        label: const P(content: 'Mode administrateur'),
      ),
    );
  }
}