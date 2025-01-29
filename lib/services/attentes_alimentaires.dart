import 'package:supabase_flutter/supabase_flutter.dart';

class AttentesAlimentaires {
  int id;
  String name;

  AttentesAlimentaires({
    required this.id,
    required this.name,
  });

  factory AttentesAlimentaires.fromJson(Map<String, dynamic> json) {
    return AttentesAlimentaires(
        id: json['id'] as int,
        name: json['name'] as String
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
    };
  }

  static final _supabase = Supabase.instance.client;

  Future<AttentesAlimentaires> create() async {
    try {
      final response = await _supabase.from('attentes_alimentaires').insert(toJson());

      return AttentesAlimentaires.fromJson(response.data);
    } catch (error) {
      return Future.error(error);
    }
  }

  static Future<List<AttentesAlimentaires>> getAll() async {
    final response = await _supabase.from('attentes_alimentaires').select().order('id', ascending: true);
    return (response as List)
        .map((e) => AttentesAlimentaires.fromJson(e))
        .toList();
  }
}