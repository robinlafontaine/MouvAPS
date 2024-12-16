import 'package:logger/logger.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';

class User {
  final String createdAt;
  final int? formId;
  final int points;
  final int pathology;
  final String userUuid;
  final int age;
  final String firstName;
  final String lastName;

  Logger logger = Logger();

  User({
    required this.createdAt,
    required this.formId,
    required this.points,
    required this.pathology,
    required this.userUuid,
    required this.age,
    required this.firstName,
    required this.lastName,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      createdAt: json['created_at'] as String,
      formId: json['form_id'] as int?,
      points: json['points'] as int,
      pathology: json['pathology_id'] as int,
      userUuid: json['user_uuid'] as String,
      age: json['age'] as int,
      firstName: json['first_name'] as String,
      lastName: json['last_name'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'created_at': createdAt,
      'form_id': formId,
      'points': points,
      'pathology': pathology,
      'user_uuid': userUuid,
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

  static Future<List<User>> getAll() async {
    final response = await _supabase
        .from('users')
        .select();
    return response.map((json) => User.fromJson(json)).toList();
  }

  Future<void> delete() async {
    await _supabase
        .from('users')
        .delete()
        .eq('user_uuid', userUuid);
  }

  static Future<User> getByUuid(String uuid) async {
    final response =
    await _supabase.from('users').select().eq('user_uuid', uuid).single();
    return User.fromJson(response);
  }

  static User empty() {
    return User(
      createdAt: '',
      formId: 0,
      points: 0,
      pathology: 0,
      userUuid: const Uuid().v4(),
      age: 0,
      firstName: '',
      lastName: '',
    );
  }
}