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
import 'package:path_provider/path_provider.dart';
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
  Difficulty difficulty;
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
      points: json['points'] is int ? json['points'] as int : 0,

      userUuid: json['user_uuid'] is String ? json['user_uuid'] as String : "",

      pathologies: (json['user_pathologie'] is List)
          ? (json['user_pathologie'] as List)
          .where((e) => e is Map && e.containsKey('pathologies'))
          .map((e) => Pathology.fromJson(e['pathologies']))
          .toList()
          : [],

      birthday: json['birthday'] is String ? DateTime.tryParse(json['birthday']) ?? DateTime(2000, 1, 1) : DateTime(2000, 1, 1),

      firstName: json['first_name'] is String ? json['first_name'] as String : "Inconnu",

      lastName: json['last_name'] is String ? json['last_name'] as String : "Inconnu",

      roles: (json['user_role'] is List)
          ? (json['user_role'] as List)
          .where((e) => e is Map && e.containsKey('roles'))
          .map((e) => Role.fromJson(e['roles']))
          .toList()
          : [],

      gender: json['gender'] is String ? json['gender'] as String : "inconnu",

      difficulty: json['user_difficulty'] is List
          ? (json['user_difficulty'] as List)
          .where((e) => e is Map && e.containsKey('niveaux'))
          .map((e) => Difficulty.fromJson(e['niveaux']))
          .isNotEmpty // Vérifie si la liste n'est pas vide
          ? (json['user_difficulty'] as List)
          .where((e) => e is Map && e.containsKey('niveaux'))
          .map((e) => Difficulty.fromJson(e['niveaux']))
          .first // Prends le premier élément
          : Difficulty(id: 1, name: "Inconnu") // Si la liste est vide
          : Difficulty(id: 1, name: "Inconnu"), // Cas où 'user_difficulty' n'est pas une liste


      diet: (json['user_regime'] is List)
          ? (json['user_regime'] as List)
          .where((e) => e is Map && e.containsKey('regimes_alimentaires'))
          .map((e) => Diet.fromJson(e['regimes_alimentaires']))
          .toList()
          : [],

      homeMaterial: (json['user_materiel_sportif'] is List)
          ? (json['user_materiel_sportif'] as List)
          .where((e) => e is Map && e.containsKey('materiel_sportif'))
          .map((e) => HomeMaterial.fromJson(e['materiel_sportif']))
          .toList()
          : [],

      allergies: (json['user_allergie'] is List)
          ? (json['user_allergie'] as List)
          .where((e) => e is Map && e.containsKey('allergies'))
          .map((e) => Allergy.fromJson(e['allergies']))
          .toList()
          : [],

      dietExpectations: (json['user_attentes_alimentaires'] is List)
          ? (json['user_attentes_alimentaires'] as List)
          .where((e) => e is Map && e.containsKey('attentes_alimentaires'))
          .map((e) => DietExpectations.fromJson(e['attentes_alimentaires']))
          .toList()
          : [],

      sportExpectations: (json['user_attentes_sportives'] is List)
          ? (json['user_attentes_sportives'] as List)
          .where((e) => e is Map && e.containsKey('attentes_sportives'))
          .map((e) => SportExpectations.fromJson(e['attentes_sportives']))
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

    // Difficulty
    await _supabase
        .from('user_difficulty')
        .delete()
        .eq('user_uuid', userUuid);

    await _supabase
        .from('user_difficulty')
        .upsert({
          'user_uuid': userUuid,
          'difficulty_id': difficulty.id,
        })
        .select()
        .single();


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
      difficulty: Difficulty(id: 1, name: "Inconnu"),
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
    try {
      final check = await _supabase.storage.from('user-data').list(path: userUuid, searchOptions: const SearchOptions(search: 'certificat'));
      logger.d(check[0].name);
      if (check.isEmpty) {
        return null;
      }
      final response = await _supabase.storage.from('user-data').download("$userUuid/${check[0].name}");
      final tempDir = await getTemporaryDirectory();
      File file = await File("${tempDir.path}/${check[0].name}").create();
      file.writeAsBytesSync(response);

      return file;
    } catch (e) {
      logger.e(e);
      return null;
    }
  }
}


