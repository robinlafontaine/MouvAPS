import 'package:supabase_flutter/supabase_flutter.dart';

class Allergie {
  int id;
  String name;

  Allergie({
    required this.id,
    required this.name,
  });

  factory Allergie.fromJson(Map<String, dynamic> json) {
    return Allergie(
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

  Future<Allergie> create() async {
    try {
      final response = await _supabase.from('allergies').insert(toJson());

      return Allergie.fromJson(response.data);
    } catch (error) {
      return Future.error(error);
    }
  }

  static Future<List<Allergie>> getAll() async {
    final response = await _supabase.from('allergies').select().order('id', ascending: true);
    return (response as List)
        .map((e) => Allergie.fromJson(e))
        .toList();
  }
}