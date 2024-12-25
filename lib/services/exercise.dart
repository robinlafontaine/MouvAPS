import 'package:logger/logger.dart';
import 'package:mouvaps/services/db.dart';
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

  Exercise({
    required this.id,
    required this.name,
    required this.url,
    required this.thumbnailUrl,
    required this.duration,
    required this.rewardPoints,
    this.tags,
  });

  factory Exercise.fromJson(Map<String, dynamic> json) {
    return Exercise(
      id: json['id'] as int,
      name: json['name'] as String,
      url: json['url'] as String,
      thumbnailUrl: json['thumbnail_url'] as String,
      duration: Duration(seconds: json['duration']),
      tags: json['tags'] as Map<String, dynamic>?,
      rewardPoints: json['reward_points'] as int,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'url': url,
      'thumbnail_url': thumbnailUrl,
      'duration': duration!.inSeconds,
      'is_unlocked': isUnlocked ? 1 : 0,
      'tags': tags,
      'reward_points': rewardPoints,
    };
  }

  static final _supabase = Supabase.instance.client;
  static final _db = ContentDatabase.instance;
  static Logger logger = Logger();

  @override
  String toString() {
    return "Exercise_$id";
  }

  void setIsUnlocked(bool value) {
    isUnlocked = value;
  }

  Exercise copyWith({
    int? id,
    String? name,
    String? url,
    String? thumbnailUrl,
    int? rewardPoints,
    Duration? duration,
    bool? isUnlocked,
    Map<String, dynamic>? tags,
  }) {
    return Exercise(
      id: id ?? this.id,
      name: name ?? this.name,
      url: url ?? this.url,
      thumbnailUrl: thumbnailUrl ?? this.thumbnailUrl,
      duration: duration ?? this.duration,
      rewardPoints: rewardPoints ?? this.rewardPoints,
      tags: tags ?? this.tags,
    );
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
        ''').eq('user_id', Auth.instance.getUUID() as String).order('playlist_order', ascending: true);

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
      final userId = Auth.instance.getUUID();

      if (userId == null) {
        throw Exception('User not logged in');
      }

      final response = await _supabase.rpc('update_playlist_progress', params: {
        'p_user_id': userId,
        'p_current_exercise_id': exercise.id,
      });

      final nextExerciseId = response;

      if (nextExerciseId != null) {
        logger.i('Next exercise unlocked: $nextExerciseId');
      } else {
        logger.i('No more exercises in the playlist');
      }

      final pointsResponse = await _supabase.rpc('increment_user_points', params: {
        'p_user_id': userId,
        'p_points_to_add': exercise.rewardPoints,
      });

      logger.i('User points updated to: $pointsResponse points');

  }

  static Future<Exercise> saveLocalExercise(Exercise exercise, String localUrl, String localThumbnailUrl) async {
    try {
      Exercise localExercise = exercise.copyWith(url: localUrl, thumbnailUrl: localThumbnailUrl);
      await _db.insert('exercises', localExercise.toJson());
      logger.i('Local exercise saved');
      return localExercise;
    } catch (e) {
      logger.e('Error saving local exercise: $e');
      return exercise;
    }
  }

  static Future<List<Exercise>> getLocalExercises() async {
    try {
      var rows = await _db.queryAllRows('exercises');
      return rows.map((row) => Exercise.fromJson(row)).toList();
    } catch (e) {
      logger.e('Error getting local exercises: $e');
      return [];
    }
  }
//TODO: Algorithmic content serving using type, tags and user points (weights TBD)
}