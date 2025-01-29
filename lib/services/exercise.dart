import 'package:logger/logger.dart';
import 'package:supabase_flutter/supabase_flutter.dart';


import 'auth.dart';

class Exercise {
  final int? id;
  final String name;
  final String url;
  final int? difficulty;
  final int? rewardPoints;
  final Map<String, dynamic>? tags;
  final DateTime? createdAt;
  static final Logger logger = Logger();

  Exercise({
    this.id,
    required this.name,
    required this.url,
    this.createdAt,
    this.tags,
    this.difficulty,
    this.rewardPoints,
  });

  factory Exercise.fromJson(Map<String, dynamic> json) {
    return Exercise(
      id: json['id'] as int?,
      name: json['name'] as String,
      url: json['url'] as String,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'].toString())
          : null,
      tags: json['tags'] as Map<String, dynamic>?,
      difficulty: json['difficulty'] as int?,
      rewardPoints: json['price_points'] as int?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'url': url,
      'tags': tags,
      'difficulty': difficulty,
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
  static Future<void> generatePlaylist() async {
    try {
      final String? userId = Auth.instance.getUUID();
      if (userId == null) {
        throw Exception('User not logged in');
      }


      final userResponse = await _supabase
          .from('users')
          .select('points, user_pathologie(pathologie_id)')
          .eq('user_uuid', userId)
          .single();


      final int userPoints = userResponse['points'];
      final List<int> userPathologies = (userResponse['user_pathologie'] as List)
          .map<int>((p) => p['pathologie_id'] as int)
          .toList();


      logger.i('Utilisateur : $userId, Points : $userPoints, Pathologies : $userPathologies');


      final exercisesResponse = await _supabase
          .from('exercises')
          .select('''
           id,
           name,
           reward_points,
           exercise_pathology_difficulties(pathology_id)
         ''')
          .lte('reward_points', userPoints);


      final List<Map<String, dynamic>> filteredExercises = (exercisesResponse as List<dynamic>)
          .map((exercise) => exercise as Map<String, dynamic>)
          .where((exercise) {
        final exercisePathologies = (exercise['exercise_pathology_difficulties'] as List<dynamic>)
            .map<int>((p) => p['pathology_id'] as int)
            .toList();
        return exercisePathologies.every((p) => !userPathologies.contains(p));
      })
          .toList();


      filteredExercises.sort((a, b) => a['reward_points'].compareTo(b['reward_points']));


      final List<Map<String, dynamic>> playlist = [];
      for (int i = 0; i < filteredExercises.length; i++) {
        playlist.add({
          'user_id': userId, // Correct column name
          'exercise_id': filteredExercises[i]['id'],
          'playlist_order': i + 1,
          'is_unlocked': userPoints >= filteredExercises[i]['reward_points'],
        });
      }


      await _supabase.from('user_exercise_playlist').insert(playlist);


      logger.i('Playlist générée avec succès pour l\'utilisateur $userId');
    } catch (e) {
      logger.e('Erreur inattendue : $e');
    }
  }
}

