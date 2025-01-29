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

  Future<void> decrementPoints(int points) async {
    final user = Auth.instance.getUser();
    if (user != null) {
      try {
        _points -= points;
        await User.decrementPointsByUuid(user.id, points);
        print('Points deduced: $points - Total points: $_points');
        notifyListeners();
      } catch (e) {
        print('Error decrementing points: $e');
      }
    }
  }

  Future<void> addPoints(int points) async {
    final user = Auth.instance.getUser();
    if (user != null) {
      await User.incrementPointsByUuid(user.id, points);
      _points += points;
      notifyListeners();
    }
  }
}
