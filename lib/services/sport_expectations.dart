import 'package:supabase_flutter/supabase_flutter.dart';

class SportExpectations{
  final int id;
  final String name;
  final String description;

  SportExpectations({
    required this.id,
    required this.name,
    required this.description,
  });

  factory SportExpectations.fromJson(Map<String, dynamic> json) {
    String desc = '';
    if(json['description'] != null){
      desc = json['description'];

    }
    return SportExpectations(
      id: json['id'] as int,
      name: json['name'] as String,
      description: desc,
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

  static Future<List<SportExpectations>> getAll() async {
    final response = await _supabase.from('attentes_sportives').select().order('id', ascending: true);
    return (response as List)
        .map((e) => SportExpectations.fromJson(e))
        .toList();
  }
}