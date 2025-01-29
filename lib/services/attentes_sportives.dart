import 'package:supabase_flutter/supabase_flutter.dart';

class AttentesSportives {
  int id;
  String name;
  String description;

  AttentesSportives({
    required this.id,
    required this.name,
    required this.description,
  });

  factory AttentesSportives.fromJson(Map<String, dynamic> json) {
    return AttentesSportives(
        id: json['id'] as int,
        name: json['name'] as String,
        description: json['description'] != null ?
          json['description'] as String : ''
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
    };
  }

  static final _supabase = Supabase.instance.client;

  Future<AttentesSportives> create() async {
    try {
      final response = await _supabase.from('attentes_sportives').insert(toJson());

      return AttentesSportives.fromJson(response.data);
    } catch (error) {
      return Future.error(error);
    }
  }

  static Future<List<AttentesSportives>> getAll() async {
    final response = await _supabase.from('attentes_sportives').select().order('id', ascending: true);
    return (response as List)
        .map((e) => AttentesSportives.fromJson(e))
        .toList();
  }
}