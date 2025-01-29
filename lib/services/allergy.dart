import 'package:supabase_flutter/supabase_flutter.dart';

class Allergy {
  final int id;
  final String name;

  Allergy({
    required this.id,
    required this.name,
  });

  factory Allergy.fromJson(Map<String, dynamic> json) {
    return Allergy(
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

  static Future<List<Allergy>> getAll() async {
    final response = await _supabase.from('allergies').select().order('id', ascending: true);
    return (response as List)
        .map((e) => Allergy.fromJson(e))
        .toList();
  }
}