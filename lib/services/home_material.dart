import 'package:supabase_flutter/supabase_flutter.dart';

class HomeMaterial {
  final int id;
  final String name;

  HomeMaterial({
    required this.id,
    required this.name,
  });

  factory HomeMaterial.fromJson(Map<String, dynamic> json) {
    return HomeMaterial(
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

  static Future<List<HomeMaterial>> getAll() async {
    final response = await _supabase.from('materiel_sportif').select().order('id', ascending: true);
    return (response as List)
        .map((e) => HomeMaterial.fromJson(e))
        .toList();
  }

}