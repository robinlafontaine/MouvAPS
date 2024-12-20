import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';

class User {
  final String userUuid;
  final int? formId;
  final int pathoId;
  final int points;
  final int age;

  User({
    required this.userUuid,
    required this.formId,
    required this.pathoId,
    required this.points,
    required this.age,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      userUuid: json['user_uuid'] as String,
      formId: json['form_id'] as int,
      pathoId: json['pathology_id'] as int,
      points: json['points'] as int,
      age: json['age'] as int,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'user_uuid': userUuid,
      'form_id': formId,
      'patho_id': pathoId,
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
  static Future<int> getPointsByUuid(String uuid) async {
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

  static Future<User> getUserByUuid(String uuid) async {
    final response =
        await _supabase.from('users').select().eq('user_uuid', uuid).single();
    return User.fromJson(response);
  }

  static User empty() {
    return User(
      userUuid: const Uuid().v4(),
      formId: 0,
      pathoId: 0,
      points: 0,
      age: 0,
    );
  }
}
