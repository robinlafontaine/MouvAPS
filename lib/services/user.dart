import 'package:logger/logger.dart';
import 'package:mouvaps/services/pathology.dart';
import 'package:mouvaps/services/role.dart';
import 'package:mouvaps/services/difficulty.dart';
import 'package:mouvaps/services/regime.dart';
import 'package:mouvaps/services/allergie.dart';
import 'package:mouvaps/services/materiel_sportif.dart';
import 'package:mouvaps/services/attentes_alimentaires.dart';
import 'package:mouvaps/services/attentes_sportives.dart';
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
  List<Regime> regimesAlimentaires;
  List<MaterielSportif> materielSportif;
  List<Allergie> allergies;
  List<AttentesAlimentaires> attentesAlimentaires;
  List<AttentesSportives> attentesSportives;

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
    required this.regimesAlimentaires,
    required this.materielSportif,
    required this.allergies,
    required this.attentesAlimentaires,
    required this.attentesSportives,
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
      regimesAlimentaires: json['user_regime'] != null ?
        (json['user_regime'] as List<dynamic>?)
          !.map((e) => Regime.fromJson(e['regimes_alimentaires']))
          .toList()
        : [],
      materielSportif: json['user_materiel_sportif'] != null ?
        (json['user_materiel_sportif'] as List<dynamic>?)
          !.map((e) => MaterielSportif.fromJson(e['materiel_sportif']))
          .toList()
        : [],
      allergies: json['user_allergie'] != null ?
        (json['user_allergie'] as List<dynamic>?)
          !.map((e) => Allergie.fromJson(e['allergies']))
          .toList()
        : [],
      attentesAlimentaires: json['user_attentes_alimentaires'] != null ?
        (json['user_attentes_alimentaires'] as List<dynamic>?)
          !.map((e) => AttentesAlimentaires.fromJson(e['attentes_alimentaires']))
          .toList()
        : [],
      attentesSportives: json['user_attentes_sportives'] != null ?
        (json['user_attentes_sportives'] as List<dynamic>?)
          !.map((e) => AttentesSportives.fromJson(e['attentes_sportives']))
          .toList()
        : [],
    );
    return user;
  }

  Map<String, dynamic> toJson() {
    return {
      'user_uuid': userUuid,
      'user_pathologie': pathologies?.map((e) => e.toJson()).toList(),
      'points': points,
      'birthday': birthday.toString(),
      'first_name': firstName,
      'last_name': lastName,
      'user_role': roles.map((e) => e.toJson()).toList(),
      'gender': gender,
      'user_difficulty': difficulty,
      'user_regime': regimesAlimentaires.map((e) => e.toJson()).toList(),
      'user_materiel_sportif': materielSportif.map((e) => e.toJson()).toList(),
      'user_allergie': allergies.map((e) => e.toJson()).toList(),
      'user_attentes_alimentaires': attentesAlimentaires.map((e) => e.toJson()).toList(),
      'user_attentes_sportives': attentesSportives.map((e) => e.toJson()).toList(),
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
      regimesAlimentaires: [],
      materielSportif: [],
      allergies: [],
      attentesAlimentaires: [],
      attentesSportives: [],
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


