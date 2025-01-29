import 'package:supabase_flutter/supabase_flutter.dart';

class DietExpectations {
  final int id;
  final String name;

  DietExpectations({
    required this.id,
    required this.name,
  });

  factory DietExpectations.fromJson(Map<String, dynamic> json) {
    return DietExpectations(
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

  static Future<List<DietExpectations>> getAll() async {
    final response = await _supabase.from('attentes_alimentaires').select();
    return (response as List)
        .map((e) => DietExpectations.fromJson(e))
        .toList();
  }
}