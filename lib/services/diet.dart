import 'package:supabase_flutter/supabase_flutter.dart';

class Diet {
  final int id;
  final String name;

  Diet({
    required this.id,
    required this.name,
  });

  factory Diet.fromJson(Map<String, dynamic> json) {
    return Diet(
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

  static Future<List<Diet>> getAll() async {
    final response = await _supabase.from('regimes_alimentaires').select().order('id', ascending: true);
    return (response as List)
        .map((e) => Diet.fromJson(e))
        .toList();
  }
}