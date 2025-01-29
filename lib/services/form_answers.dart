import 'package:logger/logger.dart';
import 'package:mouvaps/services/allergy.dart';
import 'package:mouvaps/services/diet.dart';
import 'package:mouvaps/services/diet_expectations.dart';
import 'package:mouvaps/services/home_material.dart';
import 'package:mouvaps/services/pathology.dart';
import 'package:mouvaps/services/sport_expectations.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:mouvaps/services/auth.dart';

class FormAnswers {
  String name;
  String familyName;
  // Identity
  late DateTime birthday;
  late String gender = "";
  late num height = -1;
  late num weight = -1;
  List<Pathology> pathologies = []; // Uploaded separately
  late bool pregnant;
  late String jobPhysicality;
  // Medical
  late bool medication;
  // Physical Activity
  late bool physicalActivityRegular;
  late String physicalActivityLevel;
  late bool upDownAble;
  List<HomeMaterial> homeMaterial = []; // Uploaded separately
  List<SportExpectations> sportExpectations = []; // Uploaded separately
  // Diet
  List<Diet> dietaryRestrictions = []; // Uploaded separately
  List<Allergy> allergies = []; // Uploaded separately
  List<DietExpectations> dietExpectations = []; // Uploaded separately

  FormAnswers(this.name, this.familyName);
  static final _supabase = Supabase.instance.client;
  static Logger logger = Logger();

  Map<String, dynamic> toJson() {
    return {
      'user_uuid': Auth.instance.getUUID(),
      'first_name': name,
      'family_name': familyName,
      'birthday': birthday.toIso8601String(),
      'gender': gender,
      'height': height,
      'weight': weight,
      'pregnant': pregnant,
      'physical_activity_regular': physicalActivityRegular,
      'physical_activity_level': physicalActivityLevel,
      'job_physicality': jobPhysicality,
      'medication': medication,
      'up_down_able': upDownAble,
    };
  }

  Future<bool> insert() async {
    try {
      if (name.isEmpty || familyName.isEmpty) {
        throw Exception('Name and family name cannot be empty');
      }

      List<Map<String, dynamic>> userPathologies = [];
      List<Map<String, dynamic>> userAllergies = [];
      List<Map<String, dynamic>> userDietaryRestrictions = [];
      List<Map<String, dynamic>> userDietExpectations = [];
      List<Map<String, dynamic>> userSportExpectations = [];
      List<Map<String, dynamic>> userHomeMaterial = [];

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

      for (var allergy in allergies) {
        userAllergies.add({
          'user_uuid': uuid,
          'allergie_id': allergy.id,
        });
      }

      for (var diet in dietaryRestrictions) {
        userDietaryRestrictions.add({
          'user_uuid': uuid,
          'regime_id': diet.id,
        });
      }

      for (var dietExpectation in dietExpectations) {
        userDietExpectations.add({
          'user_uuid': uuid,
          'attente_id': dietExpectation.id,
        });
      }

      for (var sportExpectation in sportExpectations) {
        userSportExpectations.add({
          'user_uuid': uuid,
          'attente_id': sportExpectation.id,
        });
      }

      for (var material in homeMaterial) {
        userHomeMaterial.add({
          'user_uuid': uuid,
          'materiel_id': material.id,
        });
      }


      if(userPathologies.isNotEmpty){
        await _supabase.from('user_pathologie').insert(userPathologies);
      }
      if(userAllergies.isNotEmpty){
        await _supabase.from('user_allergie').insert(userAllergies);
      }
      if(userDietaryRestrictions.isNotEmpty){
        await _supabase.from('user_regime').insert(userDietaryRestrictions);
      }
      if(userHomeMaterial.isNotEmpty){
        await _supabase.from('user_materiel_sportif').insert(userHomeMaterial);
      }

      await _supabase.from('user_attentes_alimentaires').insert(userDietExpectations);
      await _supabase.from('user_attentes_sportives').insert(userSportExpectations);


      return true;
    } catch (e) {
      logger.e(e);
      return false;
    }

  }

}