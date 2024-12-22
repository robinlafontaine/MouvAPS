import 'package:logger/logger.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'db.dart';
import 'ingredient.dart';

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
      difficulty: json['difficulty'] is int
          ? (json['difficulty'] as int).toDouble()
          : json['difficulty'] as double,
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
  static final _db = ContentDatabase.instance;
  static Logger logger = Logger();

  Recipe copyWith({
    int? id,
    String? name,
    String? videoUrl,
    String? imageUrl,
    List<Ingredient>? ingredients,
    String? description,
    double? difficulty,
    int? timeMins,
    int? pricePoints,
    DateTime? createdAt,
  }) {
    return Recipe(
      id: id ?? this.id,
      name: name ?? this.name,
      videoUrl: videoUrl ?? this.videoUrl,
      imageUrl: imageUrl ?? this.imageUrl,
      ingredients: ingredients ?? this.ingredients,
      description: description ?? this.description,
      difficulty: difficulty ?? this.difficulty,
      timeMins: timeMins ?? this.timeMins,
      pricePoints: pricePoints ?? this.pricePoints,
      createdAt: createdAt ?? this.createdAt,
    );
  }

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
        name,
        image_url
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
            name,
            image_url
          )
        ),
        user_recipe_status (
          user_id,
          is_unlocked
        )
      ''')
        .eq('user_recipe_status.user_id', userId)
        .eq('user_recipe_status.is_unlocked', true);

    // If attribute 'user_recipe_status' is empty, the recipe is removed from the unlocked list
    final filteredResponse = response.where((element) {
      return element['user_recipe_status'] != null &&
          element['user_recipe_status'].isNotEmpty;
    }).toList();

    return filteredResponse.map((json) => Recipe.fromJson(json)).toList();
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

  Future<void> unlockRecipe(String userId) async {
    if (id == null) {
      throw Exception('Content ID is required for unlocking');
    }

    await _supabase.from('user_recipe_status').upsert({
      'user_id': userId,
      'recipe_id': id,
      'is_unlocked': true,
    });
  }

  static Future<Recipe> saveLocalRecipe(Recipe recipe, String localUrl, String localThumbnailUrl) async {
    try {
      Recipe localRecipe = recipe.copyWith(videoUrl: localUrl, imageUrl: localThumbnailUrl);
      await _db.insert('recipes', localRecipe.toJson());
      logger.i('Local recipe saved');
      return localRecipe;
    } catch (e) {
      logger.e('Error saving local recipe: $e');
      return recipe;
    }
  }

  static Future<List<Recipe>> getLocalRecipes() async {
    try {
      var rows = await _db.queryAllRows('recipes');
      return rows.map((row) => Recipe.fromJson(row)).toList();
    } catch (e) {
      logger.e('Error getting local recipes: $e');
      return [];
    }
  }



//TODO: Algorithmic content serving using type, tags and user points (weights TBD)
}
