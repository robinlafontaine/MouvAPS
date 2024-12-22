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

  void addPoints(int points) {
    _points += points;
    notifyListeners();
  }
}
