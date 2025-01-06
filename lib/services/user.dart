import 'package:logger/logger.dart';
import 'package:mouvaps/services/pathology.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';

class User {
  final String userUuid;
  final List<Pathology>? pathologies;
  final int points;
  final int age;
  final String firstName;
  final String lastName;

  Logger logger = Logger();

  User({
    required this.userUuid,
    required this.pathologies,
    required this.points,
    required this.age,
    required this.firstName,
    required this.lastName,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      points: json['points'] as int,
      userUuid: json['user_uuid'] as String,
      pathologies: (json['user_pathologie'] as List<dynamic>?)
          ?.map((e) => Pathology.fromJson(e['pathologies']))
          .toList(),
      age: json['age'] as int,
      firstName: json['first_name'] as String,
      lastName: json['last_name'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'user_uuid': userUuid,
      'user_pathologie': pathologies?.map((e) => e.toJson()).toList(),
      'points': points,
      'age': age,
      'first_name': firstName,
      'last_name': lastName,
    };
  }

  static final _supabase = Supabase.instance.client;

  Future<User> create() async {
    final response = await _supabase
        .from('users')
        .insert(toJson())
        .select()
        .single();
    return User.fromJson(response);
  }

  Future<User> update() async {
    final response = await _supabase
        .from('users')
        .update(toJson())
        .eq('user_uuid', userUuid)
        .select()
        .single();
    return User.fromJson(response);
  }

  // Update the user's points
  Future<User> updatePoints(int points) async {
    final response = await _supabase
        .from('users')
        .update({'points': points})
        .eq('user_uuid', userUuid)
        .select()
        .single();
    return User.fromJson(response);
  }

  // Get user's points
  Future<int> getPoints() async {
    final response = await _supabase
        .from('users')
        .select('points')
        .eq('user_uuid', userUuid)
        .single();
    return response['points'] as int;
  }

  // Get user's points by user uuid
  static Future<int> getPointsByUuid(String? uuid) async {

    if (uuid == null) {
      return 0;
    }

    final response = await _supabase
        .from('users')
        .select('points')
        .eq('user_uuid', uuid)
        .single();
    return response['points'] as int;
  }

  static Future<List<User>> getAll() async {
    final response = await _supabase
        .from('users')
        .select('''
            user_uuid,
            points,
            age,
            first_name,
            last_name,
            user_pathologie (
              pathologies (
                id,
                name
              )
            )
          ''');
    return response.map((json) => User.fromJson(json)).toList();
  }

  Future<void> delete() async {
    await _supabase
        .from('users')
        .delete()
        .eq('user_uuid', userUuid);
  }

  static Future<User> getUserByUuid(String? uuid) async {

    if (uuid == null) {
      return empty();
    }

    final response =
        await _supabase.from('users')
            .select('''
            user_uuid,
            points,
            age,
            first_name,
            last_name,
            user_pathologie (
              pathologies (
                id,
                name
              )
            )
          ''')
            .eq('user_uuid', uuid).single();
    return User.fromJson(response);
  }

  static User empty() {
    return User(
      userUuid: const Uuid().v4(),
      pathologies: [],
      points: 0,
      age: 0,
      firstName: '',
      lastName: '',
    );
  }
}
