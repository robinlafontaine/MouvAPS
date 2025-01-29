import 'package:flutter/material.dart';
import '../services/user.dart';
import '../services/auth.dart';

class UserPointsNotifier extends ChangeNotifier {
  int _points = 0;

  int get points => _points;

  Future<void> fetchUserPoints() async {
    final user = Auth.instance.getUser();
    if (user != null) {
      _points = await User.getPointsByUuid(user.id);
      notifyListeners();
    }
  }

  Future<void> addPoints(int points) async {
    final user = Auth.instance.getUser();
    if (user != null) {
      await User.updatePointsByUuid(user.id, _points + points);
      _points += points;
      notifyListeners();
    }
  }
}
