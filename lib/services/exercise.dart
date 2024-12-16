import 'package:logger/logger.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class Exercise {
  final int? id;
  final String name;
  final String url;
  final String thumbnailUrl;
  final int? rewardPoints;
  final Map<String, dynamic>? tags;
  final DateTime? createdAt;
  Logger logger = Logger();

  Exercise({
    this.id,
    required this.name,
    required this.url,
    required this.thumbnailUrl,
    this.createdAt,
    this.tags,
    this.rewardPoints,
  });

  factory Exercise.fromJson(Map<String, dynamic> json) {
    return Exercise(
      id: json['id'] as int?,
      name: json['name'] as String,
      url: json['url'] as String,
      thumbnailUrl: json['thumbnail_url'] as String,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'].toString())
          : null,
      tags: json['tags'] as Map<String, dynamic>?,
      rewardPoints: json['price_points'] as int?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'url': url,
      'thumbnail_url': thumbnailUrl,
      'tags': tags,
      'price_points': rewardPoints,
    };
  }

  static final _supabase = Supabase.instance.client;

  Future<Exercise> create() async {
    final response = await _supabase
        .from('exercises')
        .insert(toJson())
        .select()
        .single();
    return Exercise.fromJson(response);
  }

  Future<Exercise> update() async {
    if (id == null) {
      throw Exception('Content ID is required for update');
    }

    final response = await _supabase
        .from('exercises')
        .update(toJson())
        .eq('id', id as int)
        .select()
        .single();

    return Exercise.fromJson(response);
  }

  static Future<Exercise> getById(int id) async {
    final response = await _supabase
        .from('exercises')
        .select()
        .eq('id', id)
        .single();

    return Exercise.fromJson(response);
  }

  static Future<List<Exercise>> getAll() async {
    final response = await _supabase
        .from('exercises')
        .select();

    return response.map((json) => Exercise.fromJson(json)).toList();
  }

  Future<void> delete() async {
    if (id == null) {
      throw Exception('Content ID is required for deletion');
    }

    await _supabase
        .from('exercises')
        .delete()
        .eq('id', id as int);
  }

  static Future<List<Exercise>> search(String query) async {
    final response = await _supabase
        .from('exercises')
        .select()
        .or(
        'name.ilike.%$query%,'
            'tags->contains.{"search_key": "$query"}'
    );

    return response.map((json) => Exercise.fromJson(json)).toList();
  }

//TODO: Algorithmic content serving using type, tags and user points (weights TBD)
}