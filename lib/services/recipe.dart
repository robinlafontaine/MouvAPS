import 'package:logger/logger.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'db.dart';
import 'ingredient.dart';

class Recipe {
  int? id;
  String? name;
  String? videoUrl;
  String? imageUrl;
  List<Ingredient>? ingredients;
  String? description;
  double? difficulty;
  int? timeMins;
  int? pricePoints;
  DateTime? createdAt;

  Recipe({
    this.id,
    this.name,
    this.videoUrl,
    this.imageUrl,
    this.ingredients,
    this.description,
    this.difficulty,
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
  static Logger logger = Logger();

  static const _ingredientQuery = '''
    SELECT 
      i.*,
      ri.quantity
    FROM recipe_ingredient ri
    JOIN ingredients i ON i.id = ri.ingredient_id
    WHERE ri.recipe_id = ?
  ''';

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

  Map<String, dynamic> _toLocalMap(String localUrl, String localThumbnailUrl) {
    return {
      'id': id,
      'name': name,
      'video_url': localUrl,
      'thumbnail_url': localThumbnailUrl,
      'description': description,
      'time_mins': timeMins,
      'created_at': createdAt?.toIso8601String(),
      'difficulty': difficulty,
      'price_points': pricePoints,
    };
  }

  static Future<Recipe> saveLocalRecipe(Recipe recipe, String localUrl,
      String localThumbnailUrl, List<String> ingredientThumbnailUrls) async {
    try {
      final db = await ContentDatabase.instance.database;

      await db.transaction((txn) async {
        final recipeMap = recipe._toLocalMap(localUrl, localThumbnailUrl);

        final existingRecipe = await txn.query(
          'recipes',
          where: 'id = ?',
          whereArgs: [recipe.id],
        );

        if (existingRecipe.isNotEmpty) {
          await txn.update(
            'recipes',
            recipeMap,
            where: 'id = ?',
            whereArgs: [recipe.id],
          );
        } else {
          await txn.insert('recipes', recipeMap);
        }

        await txn.delete(
          'recipe_ingredient',
          where: 'recipe_id = ?',
          whereArgs: [recipe.id],
        );

        if (recipe.ingredients != null) {
          await Future.wait(
            recipe.ingredients!.asMap().entries.map((entry) async {
              final i = entry.key;
              final ingredient = entry.value;

              int ingredientId;
              final existingIngredient = await txn.query(
                'ingredients',
                where: 'name = ?',
                whereArgs: [ingredient.name],
              );

              if (existingIngredient.isNotEmpty) {
                ingredientId = existingIngredient.first['id'] as int;
                await txn.update(
                  'ingredients',
                  {
                    'name': ingredient.name,
                    'image_url': ingredientThumbnailUrls[i],
                  },
                  where: 'id = ?',
                  whereArgs: [ingredientId],
                );
              } else {
                ingredientId = await txn.insert('ingredients', {
                  'name': ingredient.name,
                  'image_url': ingredientThumbnailUrls[i],
                });
              }

              return txn.insert('recipe_ingredient', {
                'recipe_id': recipe.id,
                'ingredient_id': ingredientId,
                'quantity': ingredient.quantity,
              });
            }),
          );
        }
      });

      logger.i('Local recipe saved successfully');
      return await getLocalRecipeById(recipe.id ?? 0);
    } catch (e) {
      logger.e('Error saving local recipe: $e');
      rethrow;
    }
  }

  static Future<Recipe> getLocalRecipeById(int id) async {
    try {
      final db = await ContentDatabase.instance.database;

      final recipes = await db.query(
        'recipes',
        where: 'id = ?',
        whereArgs: [id],
      );

      if (recipes.isEmpty) {
        throw Exception('Recipe not found');
      }

      final recipeData = Map<String, dynamic>.from(recipes.first);
      final ingredients = await db.rawQuery(_ingredientQuery, [id]);

      recipeData['recipe_ingredient'] = ingredients
          .map((ri) => Map<String, dynamic>.from({
                'quantity': ri['quantity'],
                'ingredient': {
                  'name': ri['name'],
                  'image_url': ri['image_url'],
                }
              }))
          .toList();

      return Recipe.fromJson(recipeData);
    } catch (e) {
      logger.e('Error getting local recipe: $e');
      rethrow;
    }
  }

  static Future<List<Recipe>> getLocalRecipes() async {
    try {
      final db = await ContentDatabase.instance.database;
      final recipes = await db.query('recipes');

      return await Future.wait(
        recipes.map((recipeRow) async {
          final recipeData = Map<String, dynamic>.from(recipeRow);
          final ingredients =
              await db.rawQuery(_ingredientQuery, [recipeData['id']]);

          recipeData['recipe_ingredient'] = ingredients
              .map((ri) => Map<String, dynamic>.from({
                    'quantity': ri['quantity'],
                    'ingredient': {
                      'name': ri['name'],
                      'image_url': ri['image_url'],
                    }
                  }))
              .toList();

          return Recipe.fromJson(recipeData);
        }),
      );
    } catch (e) {
      logger.e('Error getting local recipes: $e');
      return [];
    }
  }

//TODO: Algorithmic content serving using type, tags and user points (weights TBD)
}
