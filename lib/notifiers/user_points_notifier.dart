import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import '../services/user.dart';
import '../services/auth.dart';

class UserPointsNotifier extends ChangeNotifier {
  int _points = 0;

  int get points => _points;

  Logger logger = Logger();

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
        await User.decrementPointsByUuid(user.id, points);
        fetchUserPoints();
        notifyListeners();
      } catch (e) {
        logger.e('Error decrementing points: $e');
      }
    }
  }

  Future<void> addPoints(int points) async {
    final user = Auth.instance.getUser();
    if (user != null) {
      try {
        await User.incrementPointsByUuid(user.id, points);
        fetchUserPoints();
        notifyListeners();
      } catch (e) {
        logger.e('Error adding points: $e');
      }
    }
  }
}
