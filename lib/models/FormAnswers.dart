class FormAnswers {
  String name;
  String familyName;
  // Identity
  late int age = -1;
  late String sex = "";
  late num height = -1;
  late num weight = -1;
  late String handicap = "";
  late String family_situation = "";
  late bool retired;
  late int children;
  late bool pregnant;
  late bool home_floors;
  late int home_floors_number;
  late bool home_stairs;
  late String job;
  // Medical
  late String medical_history;
  late String risk_factors;
  late String medication;
  // Physical Activity
  late String physical_activity;
  late String current_activity;
  late String current_activity_time;
  late String current_activity_intensity = "";
  late String current_activity_frequency;
  late String activity_difficulties;
  late bool up_down_able;
  late String home_material;
  late String expectations_needs_sport;
  // Diet
  late String dietary_restrictions;
  late String allergies;
  late String food_hated;
  late String expectations_needs_diet;

  FormAnswers(this.name, this.familyName);

}