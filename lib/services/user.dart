import 'package:flutter/src/widgets/framework.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';

class User {
  final int id;
  final String userUuid;
  final int? formId;
  final int pathoId;
  final int points;
  final int age;

  User({
    required this.id,
    required this.userUuid,
    required this.formId,
    required this.pathoId,
    required this.points,
    required this.age,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] as int,
      userUuid: json['user_uuid'] as String,
      formId: json['form_id'] as int,
      pathoId: json['pathology_id'] as int,
      points: json['points'] as int,
      age: json['age'] as int,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
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

    print('response: $response');
    return User.fromJson(response);
  }

  Future<User> update() async {
    final response = await _supabase
        .from('users')
        .update(toJson())
        .eq('id', id)
        .select()
        .single();
    return User.fromJson(response);
  }

  Future<void> delete() async {
    await _supabase.from('users').delete().eq('id', id);
  }

  static Future<User> getByUuid(String uuid) async {
    print('uuid: $uuid');
    final response =
        await _supabase.from('users').select().eq('user_uuid', uuid).single();

    print('response: $response');
    return User.fromJson(response);
  }

  static User empty() {
    return User(
      id: 0,
      userUuid: const Uuid().v4(),
      formId: 0,
      pathoId: 0,
      points: 0,
      age: 0,
    );
  }
}
