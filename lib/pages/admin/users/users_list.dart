import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import 'package:mouvaps/services/user.dart';
import 'package:mouvaps/pages/admin/users/user_tile.dart';

class UserList extends StatefulWidget {
  final String role;

  const UserList({super.key,
      required this.role,
    }
  );


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
            for (var role in content.roles!) {
              print(role.name);
              if (role.name == widget.role) {
                return UserTile(
                  user: content,
                );
              }
            }
            return const SizedBox.shrink();
          }).toList());
        } else {
          return Column(
            children: [
              const CircularProgressIndicator(),
              Text(snapshot.error.toString()),
            ],
          );
        }
      },
    );
  }
}
