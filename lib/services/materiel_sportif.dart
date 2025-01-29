import 'package:supabase_flutter/supabase_flutter.dart';

class MaterielSportif {
  int id;
  String name;

  MaterielSportif({
    required this.id,
    required this.name,
  });

  factory MaterielSportif.fromJson(Map<String, dynamic> json) {
    return MaterielSportif(
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

  Future<MaterielSportif> create() async {
    try {
      final response = await _supabase.from('materiel_sportif').insert(toJson());

      return MaterielSportif.fromJson(response.data);
    } catch (error) {
      return Future.error(error);
    }
  }

  static Future<List<MaterielSportif>> getAll() async {
    final response = await _supabase.from('materiel_sportif').select().order('id', ascending: true);
    return (response as List)
        .map((e) => MaterielSportif.fromJson(e))
        .toList();
  }
}