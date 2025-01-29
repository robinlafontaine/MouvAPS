import 'package:logger/logger.dart';
import 'package:mouvaps/services/pathology.dart';
import 'package:mouvaps/services/role.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';

class User {
  final String userUuid;
  List<Pathology>? pathologies;
  int points;
  DateTime birthday;
  String firstName;
  String lastName;
  List<Role> roles;
  String gender;

  Logger logger = Logger();

  User({
    required this.userUuid,
    required this.pathologies,
    required this.points,
    required this.birthday,
    required this.firstName,
    required this.lastName,
    required this.roles,
    required this.gender,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    User user = User(
      points: json['points'] as int,
      userUuid: json['user_uuid'] as String,
      pathologies: (json['user_pathologie'] as List<dynamic>?)
          ?.map((e) => Pathology.fromJson(e['pathologies']))
          .toList(),
      birthday: DateTime.parse(json['birthday']),
      firstName: json['first_name'] as String,
      lastName: json['last_name'] as String,
      roles: (json['user_role'] as List<dynamic>?)!
          .map((e) => Role.fromJson(e['roles']))
          .toList(),
      gender: json['gender'] as String,
    );
    return user;
  }

  Map<String, dynamic> toJson() {
    return {
      'user_uuid': userUuid,
      'pathologies': pathologies?.map((e) => e.toJson()).toList(),
      'points': points,
      'birthday': birthday.toString(),
      'first_name': firstName,
      'last_name': lastName,
      'roles': roles.map((e) => e.toJson()).toList(),
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

  // Decrement the user's points by user uuid
  static Future<int> decrementPointsByUuid(String? uuid, int points) async {
    final response = await _supabase.rpc('decrement_user_points', params: {
      'p_user_id': uuid,
      'p_points_to_subtact': points,
    });

    return response;
  }

  // Increment the user's points by user uuid
  static Future<int> incrementPointsByUuid(String? uuid, int points) async {
    final response = await _supabase.rpc('increment_user_points', params: {
      'p_user_id': uuid,
      'p_points_to_add': points,
    });

    return response;
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
    final response = await _supabase.from('users').select('''
            user_uuid,
            points,
            birthday,
            first_name,
            last_name,
            user_pathologie (
              pathologies (
                id,
                name
              )
            ),
            user_role (
              roles (
                id,
                name
              )
            ),
            gender
          ''');
    return response.map((json) => User.fromJson(json)).toList();
  }

  Future<void> delete() async {
    await _supabase.from('users').delete().eq('user_uuid', userUuid);
  }

  static Future<User> getUserByUuid(String? uuid) async {
    if (uuid == null) {
      return empty();
    }

    final response = await _supabase.from('users').select('''
            user_uuid,
            points,
            birthday,
            first_name,
            last_name,
            user_pathologie (
              pathologies (
                id,
                name
              )
            ),
            user_role (
              roles (
                id,
                name
              )
            ),
            gender
          ''').eq('user_uuid', uuid).single();
    return User.fromJson(response);
  }

  static User empty() {
    return User(
      userUuid: const Uuid().v4(),
      pathologies: [],
      points: 0,
      birthday: DateTime.now(),
      firstName: '',
      lastName: '',
      roles: [],
      gender: '',
    );
  }

  static Future<bool> exists(String? uuid) async {
    try {
      if (uuid == null) {
        return false;
      }

      final response = await _supabase
          .from('users')
          .select('user_uuid')
          .eq('user_uuid', uuid)
          .single();

      return response.isNotEmpty;
    } catch (e) {
      return false;
    }
  }
}
