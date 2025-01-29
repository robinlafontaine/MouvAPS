import 'dart:io';

import 'package:logger/logger.dart';
import 'package:mouvaps/services/pathology.dart';
import 'package:mouvaps/services/role.dart';
import 'package:mouvaps/services/difficulty.dart';
import 'package:mouvaps/services/diet.dart';
import 'package:mouvaps/services/allergy.dart';
import 'package:mouvaps/services/home_material.dart';
import 'package:mouvaps/services/diet_expectations.dart';
import 'package:mouvaps/services/sport_expectations.dart';
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
  String difficulty;
  List<Diet> diet;
  List<HomeMaterial> homeMaterial;
  List<Allergy> allergies;
  List<DietExpectations> dietExpectations;
  List<SportExpectations> sportExpectations;

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
    required this.difficulty,
    required this.diet,
    required this.homeMaterial,
    required this.allergies,
    required this.dietExpectations,
    required this.sportExpectations,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    User user = User(
      points: json['points'] as int,
      userUuid: json['user_uuid'] as String,
      pathologies: json['user_pathologie'] != null ?
        (json['user_pathologie'] as List<dynamic>?)
          ?.map((e) => Pathology.fromJson(e['pathologies']))
          .toList()
        : [],
      birthday: DateTime.parse(json['birthday']),
      firstName: json['first_name'] as String,
      lastName: json['last_name'] as String,
      roles: json['user_role'] != null ?
        (json['user_role'] as List<dynamic>?)
          !.map((e) => Role.fromJson(e['roles']))
          .toList()
        : [],
      gender: json['gender'] != null ? json['gender'] as String : "inconnu",
      difficulty: json['difficulty'] != null ? Difficulty.fromJson(json['difficulty']).name : "inconnu",
      diet: json['user_regime'] != null ?
        (json['user_regime'] as List<dynamic>?)
          !.map((e) => Diet.fromJson(e['regimes_alimentaires']))
          .toList()
        : [],
      homeMaterial: json['user_materiel_sportif'] != null ?
        (json['user_materiel_sportif'] as List<dynamic>?)
          !.map((e) => HomeMaterial.fromJson(e['materiel_sportif']))
          .toList()
        : [],
      allergies: json['user_allergie'] != null ?
        (json['user_allergie'] as List<dynamic>?)
          !.map((e) => Allergy.fromJson(e['allergies']))
          .toList()
        : [],
      dietExpectations: json['user_attentes_alimentaires'] != null ?
        (json['user_attentes_alimentaires'] as List<dynamic>?)
          !.map((e) => DietExpectations.fromJson(e['attentes_alimentaires']))
          .toList()
        : [],
      sportExpectations: json['user_attentes_sportives'] != null ?
        (json['user_attentes_sportives'] as List<dynamic>?)
          !.map((e) => SportExpectations.fromJson(e['attentes_sportives']))
          .toList()
        : [],
    );
    return user;
  }

  Map<String, dynamic> toJson() {
    return {
      'user_uuid': userUuid,
      'points': points,
      'birthday': birthday.toString(),
      'first_name': firstName,
      'last_name': lastName,
      'gender': gender,
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
    // Check if user exists
    final existingUser = await _supabase
        .from('users')
        .select()
        .eq('user_uuid', userUuid)
        .maybeSingle();

    if (existingUser == null) {
      throw Exception("User with UUID $userUuid doesn't exist");
    }

    // Roles
    await _supabase
        .from('user_role')
        .delete()
        .eq('user_uuid', userUuid);

    for (final role in roles) {
      await _supabase
          .from('user_role')
          .upsert({
            'user_uuid': userUuid,
            'role_id': role.id,
          })
          .select()
          .single();
    }

    // Pathologies
    await _supabase
        .from('user_pathologie')
        .delete()
        .eq('user_uuid', userUuid);

    for (final pathology in pathologies!) {
      await _supabase
          .from('user_pathologie')
          .insert({
            'user_uuid': userUuid,
            'pathologie_id': pathology.id,
          })
          .select()
          .single();
    }

    // Diet
    await _supabase
        .from('user_regime')
        .delete()
        .eq('user_uuid', userUuid);

    for (final diet in diet) {
      await _supabase
          .from('user_regime')
          .insert({
            'user_uuid': userUuid,
            'regime_id': diet.id,
          })
          .select()
          .single();
    }

    // Home material
    await _supabase
        .from('user_materiel_sportif')
        .delete()
        .eq('user_uuid', userUuid);

    for (final material in homeMaterial) {
      await _supabase
          .from('user_materiel_sportif')
          .insert({
            'user_uuid': userUuid,
            'materiel_id': material.id,
          })
          .select()
          .single();
    }

    // Allergies
    await _supabase
        .from('user_allergie')
        .delete()
        .eq('user_uuid', userUuid);

    for (final allergy in allergies) {
      await _supabase
          .from('user_allergie')
          .insert({
            'user_uuid': userUuid,
            'allergie_id': allergy.id,
          })
          .select()
          .single();
    }

    // Diet expectations
    await _supabase
        .from('user_attentes_alimentaires')
        .delete()
        .eq('user_uuid', userUuid);

    for (final dietExpectation in dietExpectations) {
      await _supabase
          .from('user_attentes_alimentaires')
          .insert({
            'user_uuid': userUuid,
            'attente_id': dietExpectation.id,
          })
          .select()
          .single();
    }

    // Sport expectations
    await _supabase
        .from('user_attentes_sportives')
        .delete()
        .eq('user_uuid', userUuid);

    for (final sportExpectation in sportExpectations) {
      await _supabase
          .from('user_attentes_sportives')
          .insert({
            'user_uuid': userUuid,
            'attente_id': sportExpectation.id,
          })
          .select()
          .single();
    }

    // User update
    final response = await _supabase
        .from('users')
        .update(toJson())
        .eq('user_uuid', userUuid)
        .select()
        .maybeSingle();

    if (response == null) {
      throw Exception("L'utilisateur n'a pas été mis à jour !");
    }

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
            gender,
            user_difficulty (
              niveaux (
                id,
                name
              )
            ),
            user_regime (
              regimes_alimentaires (
                id,
                name
              )
            ),
            user_materiel_sportif (
              materiel_sportif (
                id,
                name
              )
            ),
            user_allergie (
              allergies (
                id,
                name
              )
            ),
            user_attentes_alimentaires (
              attentes_alimentaires (
                id,
                name
              )
            ),
            user_attentes_sportives (
              attentes_sportives (
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
            gender,
            user_difficulty (
              niveaux (
                id,
                name
              )
            ),
            user_regime (
              regimes_alimentaires (
                id,
                name
              )
            ),
            user_materiel_sportif (
              materiel_sportif (
                id,
                name
              )
            ),
            user_allergie (
              allergies (
                id,
                name
              )
            ),
            user_attentes_alimentaires (
              attentes_alimentaires (
                id,
                name
              )
            ),
            user_attentes_sportives (
              attentes_sportives (
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
      birthday: DateTime.now(),
      firstName: '',
      lastName: '',
      roles: [],
      gender: '',
      difficulty: '',
      diet: [],
      homeMaterial: [],
      allergies: [],
      dietExpectations: [],
      sportExpectations: [],
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

  Future<File?> getCertificate() async {
    logger.d(userUuid);

    final check = await _supabase.storage.from('user-data').list(path: userUuid, searchOptions: const SearchOptions(search: 'certificat'));
    logger.d(check[0].name);
    if (check.isEmpty) {
      return null;
    }
    try {
      final response = await _supabase.storage.from('user-data').download("$userUuid/${check[0].name}");
      final file = File.fromRawPath(response);
      return file;
    } catch (e) {
      logger.e(e);
      return null;
    }
  }
}


