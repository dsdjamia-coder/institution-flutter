import '../models/student.dart';
import '../models/payment.dart';

/// Anti-Duplicate & Anti-Collision Engine
class DuplicateGuard {
  /// Check if an admission number already exists in the institution
  static bool isAdmissionNoDuplicate(
    String admNo,
    List<Student> students, {
    String? excludeStudentId,
  }) {
    final cleanAdm = admNo.trim().toUpperCase();
    if (cleanAdm.isEmpty) return false;

    return students.any((s) {
      if (excludeStudentId != null && s.id == excludeStudentId) return false;
      return s.adm.trim().toUpperCase() == cleanAdm;
    });
  }

  /// Check if a student with identical name + class + guardian/phone already exists
  static Student? findDuplicateCandidate(
    String name,
    String studentClass,
    String father,
    String mobile,
    List<Student> students, {
    String? excludeStudentId,
  }) {
    final cleanName = name.trim().toUpperCase();
    final cleanClass = studentClass.trim().toUpperCase();
    final cleanFather = father.trim().toUpperCase();
    final cleanMobile = mobile.trim();

    if (cleanName.isEmpty) return null;

    for (final s in students) {
      if (excludeStudentId != null && s.id == excludeStudentId) continue;

      final sName = s.name.trim().toUpperCase();
      final sClass = s.studentClass.trim().toUpperCase();
      final sFather = s.father.trim().toUpperCase();
      final sMobile = s.mobile.trim();

      if (sName == cleanName && sClass == cleanClass) {
        if ((cleanFather.isNotEmpty && sFather == cleanFather) ||
            (cleanMobile.isNotEmpty && sMobile == cleanMobile)) {
          return s;
        }
      }
    }
    return null;
  }

  /// Check if another student has the exact same name in the same class (for advisory warning)
  static Student? findSameNameInClass(
    String name,
    String studentClass,
    List<Student> students, {
    String? excludeStudentId,
  }) {
    final cleanName = name.trim().toUpperCase();
    final cleanClass = studentClass.trim().toUpperCase();

    if (cleanName.isEmpty) return null;

    for (final s in students) {
      if (excludeStudentId != null && s.id == excludeStudentId) continue;
      if (s.name.trim().toUpperCase() == cleanName &&
          s.studentClass.trim().toUpperCase() == cleanClass) {
        return s;
      }
    }
    return null;
  }

  /// Unique Ledger Key generator for fee payments
  static String generateLedgerKey({
    required String studentId,
    required String academicYear,
    required String itemKey,
    required String period,
  }) {
    final sId = studentId.trim();
    final yr = academicYear.trim();
    final itm = itemKey.trim().toLowerCase();
    final prd = period.trim().toLowerCase();
    return '${sId}_${yr}_${itm}_$prd';
  }

  /// Check if a fee item for a period is already paid
  static bool isFeeItemPaid({
    required String studentId,
    required String academicYear,
    required String itemKey,
    required String period,
    required List<Payment> payments,
  }) {
    final targetLedgerKey = generateLedgerKey(
      studentId: studentId,
      academicYear: academicYear,
      itemKey: itemKey,
      period: period,
    );

    for (final payment in payments) {
      if (payment.studentId != studentId || payment.status != 'VALID') continue;
      for (final item in payment.feeItems) {
        if (item.ledgerKey == targetLedgerKey) {
          return true;
        }
      }
    }
    return false;
  }
}
