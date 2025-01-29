import 'package:flutter/material.dart';
import 'package:mouvaps/utils/text_utils.dart';
import 'package:mouvaps/pages/admin/users/users_list.dart';

class UsersPage extends StatelessWidget {
  const UsersPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const SingleChildScrollView(
      child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
        children:[
          H2(content: 'En attente'),
          UserList(role: "PENDING"),
          H2(content: 'Vérifiés'),
          UserList(role: "VERIFIED"),
          H2(content: 'Administrateurs'),
          UserList(role: "ADMIN"),
        ]
      ),
    );
  }
}