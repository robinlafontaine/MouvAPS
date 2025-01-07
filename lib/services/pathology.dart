import 'package:supabase_flutter/supabase_flutter.dart';

class Pathology {
  int id;
  String name;

  Pathology({
    required this.id,
    required this.name,
  });

  factory Pathology.fromJson(Map<String, dynamic> json) {
    return Pathology(
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

  Future<Pathology> create() async {
    try {
      final response = await _supabase.from('pathologies').insert(toJson());

      return Pathology.fromJson(response.data);
    } catch (error) {
      return Future.error(error);
    }
  }

  static Future<List<Pathology>> getAll() async {
    final response = await _supabase.from('pathologies').select().order('id', ascending: true);
    return (response as List)
        .map((e) => Pathology.fromJson(e))
        .toList();
  }
}