import 'package:supabase_flutter/supabase_flutter.dart';

class Ingredient {
  final String name;
  final int? quantity;
  final String imageUrl;

  Ingredient({
    required this.name,
    this.quantity,
    required this.imageUrl,
  });

  factory Ingredient.fromJson(Map<String, dynamic> json) {
    return Ingredient(
      name: json['ingredient']['name'] as String,
      quantity: json['quantity'] as int?,
      imageUrl: json['ingredient']['image_url'] as String,
    );
  }

  factory Ingredient.fromJson2(Map<String, dynamic> json) {
    return Ingredient(
      name: json['name'] as String,
      imageUrl: json['image_url'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'quantity': quantity,
      'image_url': imageUrl,
    };
  }

  Ingredient copyWith({
    String? name,
    int? quantity,
    String? imageUrl,
  }) {
    return Ingredient(
      name: name ?? this.name,
      quantity: quantity ?? this.quantity,
      imageUrl: imageUrl ?? this.imageUrl,
    );
  }

  static final _supabase = Supabase.instance.client;

  // Get all ingredients from the database
  static Future<List<Ingredient>> getAll() async {
    final response = await _supabase.from('ingredients').select('''
    name,
    image_url
  ''');

    return response.map((json) => Ingredient.fromJson2(json)).toList();
  }
}
