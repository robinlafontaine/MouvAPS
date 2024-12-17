import 'package:logger/logger.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'auth.dart';

class Exercise {
  final int? id;
  final String name;
  final String url;
  final String thumbnailUrl;
  final int? rewardPoints;
  final Duration? duration;
  bool isUnlocked = true;
  final Map<String, dynamic>? tags;
  final DateTime? createdAt;
  Logger logger = Logger();

  Exercise({
    required this.id,
    required this.name,
    required this.url,
    required this.thumbnailUrl,
    required this.duration,
    required this.rewardPoints,
    this.tags,
    this.createdAt,
  });

  factory Exercise.fromJson(Map<String, dynamic> json) {
    return Exercise(
      id: json['id'] as int,
      name: json['name'] as String,
      url: json['url'] as String,
      thumbnailUrl: json['thumbnail_url'] as String,
      duration: Duration(seconds: json['duration']),
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'].toString())
          : null,
      tags: json['tags'] as Map<String, dynamic>?,
      rewardPoints: json['reward_points'] as int,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'url': url,
      'duration': duration,
      'thumbnail_url': thumbnailUrl,
      'tags': tags,
      'price_points': rewardPoints,
    };
  }

  static final _supabase = Supabase.instance.client;

  void setIsUnlocked(bool value) {
    isUnlocked = value;
  }

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
        .from('user_exercise_playlist')
        .select('''
          is_unlocked,
          exercises (
            id,
            name,
            url,
            thumbnail_url,
            duration,
            reward_points,
            tags,
            created_at
          )
        ''').order('playlist_order', ascending: true);

    return (response as List).map((json) {
      final exercise = Exercise.fromJson(json['exercises']);
      exercise.setIsUnlocked(json['is_unlocked']);
      return exercise;
    }).toList();
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

  static Future<void> watched(Exercise exercise) async {
    try {
      final userId = Auth.instance.getUUID();

      //TODO: fix backend function
      await _supabase.rpc('update_playlist_progress', params: {
        'p_user_id': userId,
        'p_current_exercise_id': exercise.id,
      });

      final response = await _supabase.rpc('increment_user_points', params: {
        'p_user_id': userId,
        'p_points_to_add': exercise.rewardPoints,
      });

      print('User points updated to: ${response} points');

      } catch (error) {
       print('Error completing exercise: $error');
    }
  }
//TODO: Algorithmic content serving using type, tags and user points (weights TBD)
}