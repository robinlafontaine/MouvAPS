import 'package:flutter/material.dart';
import 'package:shadcn_ui/shadcn_ui.dart';
import 'package:mouvaps/globals/globals.dart' as globals;

class ProfileSwitch extends StatefulWidget {
  const ProfileSwitch({super.key});

  @override
  State<ProfileSwitch> createState() => _ProfileSwitchState();
}

class _ProfileSwitchState extends State<ProfileSwitch> {
  bool value = false;

  void handleToggle(bool newValue) {
    setState(() => value = newValue);
    globals.isAdmin = newValue;
  }

  @override
  Widget build(BuildContext context) {
    return ShadSwitch(
      value: value,
      onChanged: (v) => handleToggle(v),
      label: const Text('Mode administrateur'),
    );
  }
}