import 'package:supabase_flutter/supabase_flutter.dart';

class Difficulty {
  int id;
  String name;

  Difficulty({
    required this.id,
    required this.name,
  });

  factory Difficulty.fromJson(Map<String, dynamic> json) {
    return Difficulty(
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

  Future<Difficulty> create() async {
    try {
      final response = await _supabase.from('difficulties').insert(toJson());

      return Difficulty.fromJson(response.data);
    } catch (error) {
      return Future.error(error);
    }
  }

  static Future<List<Difficulty>> getAll() async {
    final response = await _supabase.from('difficulties').select().order('id', ascending: true);
    return (response as List)
        .map((e) => Difficulty.fromJson(e))
        .toList();
  }
}