import 'package:logger/logger.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class Content {
  final int? id;
  final String name;
  final String type;
  final String category;
  final String url;
  final int? points;
  final DateTime? createdAt;
  final Map<String, dynamic>? tags;
  final int? unlockPoints;
  Logger logger = Logger();

  Content({
    this.id,
    required this.name,
    required this.type,
    required this.category,
    required this.url,
    this.points,
    this.createdAt,
    this.tags,
    this.unlockPoints,
  });

  factory Content.fromJson(Map<String, dynamic> json) {
    return Content(
      id: json['id'] as int?,
      name: json['name'] as String,
      type: json['type'] as String,
      category: json['category'] as String,
      url: json['url'] as String,
      points: json['points'] as int?,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'].toString())
          : null,
      tags: json['tags'] as Map<String, dynamic>?,
      unlockPoints: json['unlock_points'] as int?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'type': type,
      'category': category,
      'url': url,
      'points': points,
      'tags': tags,
      'unlock_points': unlockPoints,
    };
  }

  static final _supabase = Supabase.instance.client;

  Future<Content> create() async {
    final response = await _supabase
        .from('content')
        .insert(toJson())
        .select()
        .single();
    return Content.fromJson(response);
  }

  Future<Content> update() async {
    if (id == null) {
      throw Exception('Content ID is required for update');
    }

    final response = await _supabase
        .from('content')
        .update(toJson())
        .eq('id', id as int)
        .select()
        .single();

    return Content.fromJson(response);
  }

  static Future<Content> getById(int id) async {
    final response = await _supabase
        .from('content')
        .select()
        .eq('id', id)
        .single();

    return Content.fromJson(response);
  }

  static Future<List<Content>> getAll() async {
    final response = await _supabase
        .from('content')
        .select();

    return response.map((json) => Content.fromJson(json)).toList();
  }

  static Future<List<Content>> getByType(String type) async {
    final response = await _supabase
        .from('content')
        .select()
        .eq('type', type);

    return response.map((json) => Content.fromJson(json)).toList();
  }

  Future<void> delete() async {
    if (id == null) {
      throw Exception('Content ID is required for deletion');
    }

    await _supabase
        .from('content')
        .delete()
        .eq('id', id as int);
  }

  static Future<List<Content>> search(String query) async {
    final response = await _supabase
        .from('content')
        .select()
        .or(
        'name.ilike.%$query%,'
            'tags->contains.{"search_key": "$query"}'
    );

    return response.map((json) => Content.fromJson(json)).toList();
  }

  static Uri getUri(Content content) {
    _supabase.storage.setAuth(_supabase.auth.currentSession!.accessToken);
    final response = _supabase
        .storage
        .from('media-content')
        .getPublicUrl(content.url);
    print(response);
    return Uri.parse(response.toString() ?? '');
  }
  //TODO: Algorithmic content serving using type, tags and user points (weights TBD)
}