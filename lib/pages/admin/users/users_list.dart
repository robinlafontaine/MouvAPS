import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import 'package:mouvaps/services/user.dart';
import 'package:mouvaps/pages/admin/users/user_tile.dart';

class UserList extends StatefulWidget {
  const UserList({super.key});

  @override
  State<StatefulWidget> createState() {
    return _UserListState();
  }
}

class _UserListState extends State<UserList> {
  Logger logger = Logger();
  final Future<List<User>> _users = User.getAll();

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: _users,
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          return Column(children: snapshot.data!.map((content) {
                return UserTile(
                  firstName: content.firstName,
                  lastName: content.lastName,
                  points: content.points,
                  age: content.age,
                  pathologies: content.pathologies,
                );
              }).toList());
        } else {
          return const CircularProgressIndicator();
        }
      },
    );
  }
}
