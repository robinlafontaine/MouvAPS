import 'package:supabase_flutter/supabase_flutter.dart';

class Regime {
  int id;
  String name;

  Regime({
    required this.id,
    required this.name,
  });

  factory Regime.fromJson(Map<String, dynamic> json) {
    return Regime(
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

  Future<Regime> create() async {
    try {
      final response = await _supabase.from('regimes_alimentaires').insert(toJson());

      return Regime.fromJson(response.data);
    } catch (error) {
      return Future.error(error);
    }
  }

  static Future<List<Regime>> getAll() async {
    final response = await _supabase.from('regimes_alimentaires').select().order('id', ascending: true);
    return (response as List)
        .map((e) => Regime.fromJson(e))
        .toList();
  }
}