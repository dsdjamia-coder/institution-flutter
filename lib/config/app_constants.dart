/// Application Constants and Configuration
class AppConstants {
  static const String institutionId = 'TEST_INSTITUTE_01';
  static const String projectId = 'institution-db743';
  static const String apiKey = 'AIzaSyCRlnf6B82HpYB1hPEFORF2yAkj3zMv7Xg';
  static const String firestoreBaseUrl =
      'https://firestore.googleapis.com/v1/projects/$projectId/databases/(default)/documents/institutions/$institutionId';

  // Default Fallbacks (100% White-Label: Overridden by Admin Settings)
  static const String defaultAppName = 'Institution Management Portal';
  static const String defaultInstitutionName = 'Institution Management System';
  static const String defaultType = 'Educational Institution';
  static const String defaultCurrency = '₹';
  static const String defaultAcademicYear = '2026-2027';

  // Role Names
  static const String roleSuperAdmin = 'super_admin';
  static const String roleClassTeacher = 'class_teacher';
  static const String roleFeeCollector = 'fee_collector';
  static const String roleResultOperator = 'result_operator';
  static const String roleStudent = 'student';
}
