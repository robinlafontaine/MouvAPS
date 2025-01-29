import 'package:supabase_flutter/supabase_flutter.dart';

class Role {
  int id;
  String name;

  Role({
    required this.id,
    required this.name,
  });

  factory Role.fromJson(Map<String, dynamic> json) {
    return Role(
      id: json['id'] as int,
      name: json['name'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
    };
  }

  static final _supabase = Supabase.instance.client;

  Future<Role> create() async {
    try {
      final response = await _supabase.from('roles').insert(toJson());

      return Role.fromJson(response.data);
    } catch (error) {
      return Future.error(error);
    }
  }

  static Future<List<Role>> getAll() async {
    final response = await _supabase.from('roles').select().order('id', ascending: true);
    return (response as List)
        .map((e) => Role.fromJson(e))
        .toList();
  }
}