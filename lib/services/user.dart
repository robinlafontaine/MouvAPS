import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';

class User {
  final String userUuid;
  final int? formId;
  final List<int>? pathologies;
  final int points;
  final int age;

  User({
    required this.userUuid,
    required this.formId,
    required this.pathologies,
    required this.points,
    required this.age,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      userUuid: json['user_uuid'] as String,
      formId: json['form_id'] as int,
      pathologies: (json['user_pathologie'] as List<dynamic>?)
          ?.map((e) => e['pathologie_id'] as int)
          .toList(),
      points: json['points'] as int,
      age: json['age'] as int,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'user_uuid': userUuid,
      'form_id': formId,
      'user_pathologie': pathologies?.map((e) => {'pathologie_id': e}).toList(),
      'points': points,
      'age': age,
    };
  }

  static final _supabase = Supabase.instance.client;

  Future<User> create() async {
    final response =
        await _supabase.from('users').insert(toJson()).select().single();

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

  Future<void> delete() async {
    await _supabase.from('users').delete().eq('user_uuid', userUuid);
  }

  static Future<User> getUserByUuid(String? uuid) async {

    if (uuid == null) {
      return empty();
    }

    final response =
        await _supabase.from('users')
            .select('''
            user_uuid,
            form_id,
            points,
            age,
            user_pathologie (
              pathologie_id
            )
          ''')
            .eq('user_uuid', uuid).single();
    return User.fromJson(response);
  }

  static User empty() {
    return User(
      userUuid: const Uuid().v4(),
      formId: 0,
      pathologies: [],
      points: 0,
      age: 0,
    );
  }

  static Future<bool> exists(String? uuid) async {
    if (uuid == null) {
      return false;
    }

    final response = await _supabase
        .from('users')
        .select('user_uuid')
        .eq('user_uuid', uuid)
        .single();
    return response.isNotEmpty;
  }
}
