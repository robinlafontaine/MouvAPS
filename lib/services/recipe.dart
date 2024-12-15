import 'package:logger/logger.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class Recipe {
  final int? id;
  final String name;
  final String videoUrl;
  final String descriptionUrl;
  final String difficulty;
  final int? timeMins;
  final int? pricePoints;
  final DateTime? createdAt;
  Logger logger = Logger();

  Recipe({
    this.id,
    required this.name,
    required this.videoUrl,
    required this.descriptionUrl,
    required this.difficulty,
    this.timeMins,
    this.pricePoints,
    this.createdAt,
  });

  factory Recipe.fromJson(Map<String, dynamic> json) {
    return Recipe(
      id: json['id'] as int?,
      name: json['name'] as String,
      videoUrl: json['video_url'] as String,
      descriptionUrl: json['description_url'] as String,
      difficulty: json['difficulty'] as String,
      timeMins: json['time_mins'] as int?,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'].toString())
          : null,
      pricePoints: json['price_points'] as int?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'video_url': videoUrl,
      'description_url': descriptionUrl,
      'time_mins': timeMins,
      'created_at': createdAt,
      'difficulty': difficulty,
      'price_points': pricePoints,
    };
  }

  static final _supabase = Supabase.instance.client;

  Future<Recipe> create() async {
    final response = await _supabase
        .from('recipes')
        .insert(toJson())
        .select()
        .single();
    return Recipe.fromJson(response);
  }

  Future<Recipe> update() async {
    if (id == null) {
      throw Exception('Content ID is required for update');
    }

    final response = await _supabase
        .from('recipes')
        .update(toJson())
        .eq('id', id as int)
        .select()
        .single();

    return Recipe.fromJson(response);
  }

  static Future<Recipe> getById(int id) async {
    final response = await _supabase
        .from('recipes')
        .select()
        .eq('id', id)
        .single();

    return Recipe.fromJson(response);
  }

  static Future<List<Recipe>> getAll() async {
    final response = await _supabase
        .from('recipes')
        .select();

    return response.map((json) => Recipe.fromJson(json)).toList();
  }

  Future<void> delete() async {
    if (id == null) {
      throw Exception('Content ID is required for deletion');
    }

    await _supabase
        .from('recipes')
        .delete()
        .eq('id', id as int);
  }

  static Future<List<Recipe>> search(String query) async {
    final response = await _supabase
        .from('recipes')
        .select()
        .or(
        'name.ilike.%$query%,'
            'tags->contains.{"search_key": "$query"}'
    );

    return response.map((json) => Recipe.fromJson(json)).toList();
  }

//TODO: Algorithmic content serving using type, tags and user points (weights TBD)
}