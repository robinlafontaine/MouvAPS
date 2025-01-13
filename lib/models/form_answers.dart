import 'package:logger/logger.dart';
import 'package:mouvaps/services/pathology.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:mouvaps/services/auth.dart';
import 'package:mouvaps/services/difficulty.dart';

class FormAnswers {
  String name;
  String familyName;
  // Identity
  late int age = -1;
  late String sex = "";
  late num height = -1;
  late num weight = -1;
  late String handicap = "";
  late String familySituation = "";
  late bool retired;
  late int children;
  late bool pregnant;
  late bool homeFloors;
  late int homeFloorsNumber = -1;
  late bool homeStairs;
  late String job;
  // Medical
  late String medicalHistory;
  late String riskFactors;
  late String medication = "";
  // Physical Activity
  late String physicalActivity = "";
  late String currentActivity = "";
  late String currentActivityTime = "";
  late String currentActivityIntensity = "";
  late String currentActivityFrequency = "";
  late String activityDifficulties = "";
  late List<Difficulty> difficulties; // Uploaded separately  late bool upDownAble;
  late bool upDownAble;
  late String homeMaterial;
  late String expectationsNeedsSport;
  // Diet
  late String dietaryRestrictions;
  late List<Pathology> pathologies; // Uploaded separately
  late String allergies;
  late String foodHated;
  late String expectationsNeedsDiet;

  FormAnswers(this.name, this.familyName);
  static final _supabase = Supabase.instance.client;
  static Logger logger = Logger();

  Map<String, dynamic> toJson() {
    return {
      'user_uuid': Auth.instance.getUUID(),
      'first_name': name,
      'family_name': familyName,
      'age': age,
      'sex': sex,
      'height': height,
      'weight': weight,
      'handicap': handicap,
      'family_situation': familySituation,
      'retired': retired,
      'children': children,
      'pregnant': pregnant,
      'home_floors': homeFloors,
      'home_floors_number': homeFloorsNumber,
      'home_stairs': homeStairs,
      'job': job,
      'medical_history': medicalHistory,
      'risk_factors': riskFactors,
      'medication': medication,
      'physical_activity_past': physicalActivity,
      'current_activity': currentActivity,
      'current_activity_time': currentActivityTime,
      'current_activity_intensity': currentActivityIntensity,
      'current_activity_frequency': currentActivityFrequency,
      'activity_difficulties': activityDifficulties,
      'up_down_able': upDownAble,
      'home_material': homeMaterial,
      'expectations_needs_sport': expectationsNeedsSport,
      'dietary_restrictions': dietaryRestrictions,
      'allergies': allergies,
      'food_hated': foodHated,
      'expectations_needs_diet': expectationsNeedsDiet,
    };
  }

  Future<bool> insert() async {
    try {
      if (name.isEmpty || familyName.isEmpty) {
        throw Exception('Name and family name cannot be empty');
      }

      List<Map<String, dynamic>> userPathologies = [];
      List<Map<String, dynamic>> userDifficulties = [];

      final uuid = Auth.instance.getUUID();
      final form = await _supabase.from('form').insert([toJson()]).select();

      if (form.isEmpty) {
        throw Exception('Failed to insert form answers');
      }

      final user = await _supabase.from('users').select().eq(
          'user_uuid', uuid as String).single();

      if (user.isEmpty) {
        throw Exception('Failed to get user');
      }

      for (var pathology in pathologies) {
        userPathologies.add({
          'user_uuid': uuid,
          'pathologie_id': pathology.id,
        });
      }

      for (var difficulty in difficulties) {
        userDifficulties.add({
          'user_uuid': uuid,
          'difficulty_id': difficulty.id,
        });
      }

      await _supabase.from('user_pathologie').insert(userPathologies);

      await _supabase.from('user_difficulty').insert(userPathologies);

      return true;
    } catch (e) {
      logger.e(e);
      return false;
    }

  }

}