import 'package:logger/logger.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class Recipe {
  final int? id;
  final String name;
  final String videoUrl;
  final String imageUrl;
  final List<Ingredient>? ingredients;
  final String description;
  final double difficulty;
  final int? timeMins;
  final int? pricePoints;
  final DateTime? createdAt;
  Logger logger = Logger();

  Recipe({
    this.id,
    required this.name,
    required this.videoUrl,
    required this.imageUrl,
    required this.ingredients,
    required this.description,
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
      imageUrl: json['thumbnail_url'] as String,
      ingredients: (json['recipe_ingredient'] as List<dynamic>?)
          ?.map((e) => Ingredient.fromJson(e))
          .toList(),
      description: json['description'] as String,
      difficulty: json['difficulty'] as double,
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
      'thumbnail_url': imageUrl,
      'ingredients': ingredients?.map((e) => e.toJson()).toList(),
      'description': description,
      'time_mins': timeMins,
      'created_at': createdAt?.toIso8601String(),
      'difficulty': difficulty,
      'price_points': pricePoints,
    };
  }

  static final _supabase = Supabase.instance.client;

  Future<Recipe> create() async {
    final response =
        await _supabase.from('recipes').insert(toJson()).select().single();
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
    final response =
        await _supabase.from('recipes').select().eq('id', id).single();

    return Recipe.fromJson(response);
  }

  static Future<List<Recipe>> getAll() async {
    final response = await _supabase.from('recipes').select('''
    id,
    name,
    video_url,
    thumbnail_url,
    description,
    difficulty,
    time_mins,
    created_at,
    price_points,
    recipe_ingredient (
      quantity,
      ingredient: ingredients (
        name
      )
    )
  ''');

    return response.map((json) => Recipe.fromJson(json)).toList();
  }

  static Future<List<Recipe>> getRecipeUnlockedByUserId(String userId) async {
    final response = await _supabase
        .from('recipes')
        .select('''
        id,
        name,
        video_url,
        thumbnail_url,
        description,
        difficulty,
        time_mins,
        created_at,
        price_points,
        recipe_ingredient (
          quantity,
          ingredient: ingredients (
            name
          )
        ),
        user_recipe_status (
          user_id,
          is_unlocked
        )
      ''')
        .eq('user_recipe_status.user_id', userId)
        .eq('user_recipe_status.is_unlocked', true);

    return response.map((json) => Recipe.fromJson(json)).toList();
  }

  Future<void> delete() async {
    if (id == null) {
      throw Exception('Content ID is required for deletion');
    }

    await _supabase.from('recipes').delete().eq('id', id as int);
  }

  static Future<List<Recipe>> search(String query) async {
    final response =
        await _supabase.from('recipes').select().or('name.ilike.%$query%,'
            'tags->contains.{"search_key": "$query"}');

    return response.map((json) => Recipe.fromJson(json)).toList();
  }

//TODO: Algorithmic content serving using type, tags and user points (weights TBD)
}

class Ingredient {
  final String name;
  final int quantity;

  Ingredient({
    required this.name,
    required this.quantity,
  });

  factory Ingredient.fromJson(Map<String, dynamic> json) {
    return Ingredient(
      name: json['ingredient']['name'] as String,
      quantity: json['quantity'] as int,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'quantity': quantity,
    };
  }
}
