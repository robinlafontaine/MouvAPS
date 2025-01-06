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
  late int homeFloorsNumber;
  late bool homeStairs;
  late String job;
  // Medical
  late String medicalHistory;
  late String riskFactors;
  late String medication;
  // Physical Activity
  late String physicalActivity;
  late String currentActivity;
  late String currentActivityTime;
  late String currentActivityIntensity = "";
  late String currentActivityFrequency;
  late String activityDifficulties;
  late bool upDownAble;
  late String homeMaterial;
  late String expectationsNeedsSport;
  // Diet
  late String dietaryRestrictions;
  late String pathologies;
  late String allergies;
  late String foodHated;
  late String expectationsNeedsDiet;

  FormAnswers(this.name, this.familyName);

}