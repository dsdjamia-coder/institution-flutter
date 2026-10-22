import 'package:flutter/material.dart';
import '../models/institution_setting.dart';
import '../models/student.dart';
import '../models/payment.dart';
import '../models/staff.dart';
import '../models/exam_result.dart';
import '../models/notice.dart';
import '../models/gallery_item.dart';
import '../models/academic_year.dart';
import '../models/student_group.dart';
import '../models/fee_concession.dart';
import '../models/custom_fee_item.dart';
import '../models/audit_log.dart';
import '../services/firestore_service.dart';
import '../services/duplicate_guard.dart';

class InstitutionProvider extends ChangeNotifier {
  final FirestoreService _firestoreService = FirestoreService();

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  // Light theme locked
  final ThemeMode _themeMode = ThemeMode.light;
  ThemeMode get themeMode => _themeMode;
  bool get isDarkMode => false;

  InstitutionSetting _setting = InstitutionSetting();
  InstitutionSetting get setting => _setting;

  List<String> _classes = [];
  List<String> get classes => _classes;

  List<Student> _students = [];
  List<Student> get students => _students;

  List<Payment> _payments = [];
  List<Payment> get payments => _payments;

  List<Staff> _staffList = [];
  List<Staff> get staffList => _staffList;

  List<ExamResult> _examResults = [];
  List<ExamResult> get examResults => _examResults;

  List<Notice> _notices = [];
  List<Notice> get notices => _notices;

  List<GalleryItem> _gallery = [];
  List<GalleryItem> get gallery => _gallery;

  List<AcademicYearConfig> _academicYears = [];
  List<AcademicYearConfig> get academicYears => _academicYears;

  List<StudentGroup> _studentGroups = [];
  List<StudentGroup> get studentGroups => _studentGroups;

  List<FeeConcession> _concessions = [];
  List<FeeConcession> get concessions => _concessions;

  List<CustomFeeItem> _customFeeItems = [];
  List<CustomFeeItem> get customFeeItems => _customFeeItems;

  List<AuditLogEntry> _auditLogs = [];
  List<AuditLogEntry> get auditLogs => _auditLogs;

  // Active User Sessions
  String? _currentRole;
  String? get currentRole => _currentRole;

  Student? _currentStudent;
  Student? get currentStudent => _currentStudent;

  Staff? _currentStaff;
  Staff? get currentStaff => _currentStaff;

  // Calculated Metrics
  int get totalStudents => _students.length;
  int get totalActiveStudents =>
      _students.where((s) => s.status.toLowerCase() == 'active').length;
  int get totalBoys =>
      _students.where((s) => s.status.toLowerCase() == 'active' && s.gender.toLowerCase() == 'male').length;
  int get totalGirls =>
      _students.where((s) => s.status.toLowerCase() == 'active' && s.gender.toLowerCase() == 'female').length;
  int get totalStaff => _staffList.length;

  // Filtered lists for strict portal isolation
  List<Student> get activeStudents =>
      _students.where((s) => s.status == 'Active').toList();

  List<Student> get alumniStudents =>
      _students.where((s) => s.status == 'Alumni' || s.studentClass.toLowerCase() == 'alumni').toList();

  List<Student> get discontinuedStudents =>
      _students.where((s) => s.status == 'Discontinued').toList();

  double get todayCollection {
    final today = DateTime.now().toString().split(' ')[0];
    return _payments
        .where((p) => p.paymentDate == today && p.status == 'VALID')
        .fold(0.0, (acc, curr) => acc + curr.amount);
  }

  double get thisMonthCollection {
    final now = DateTime.now();
    final ym = '${now.year}-${now.month.toString().padLeft(2, '0')}';
    return _payments
        .where((p) => p.paymentDate.startsWith(ym) && p.status == 'VALID')
        .fold(0.0, (acc, curr) => acc + curr.amount);
  }

  int get nextReceiptNo {
    if (_payments.isEmpty) return 1001;
    final maxReceipt = _payments.map((p) => p.receiptNo).fold(1000, (a, b) => a > b ? a : b);
    return maxReceipt + 1;
  }

  // ==================== INITIALIZATION ====================
  Future<void> init() async {
    _isLoading = true;
    notifyListeners();

    try {
      _setting = await _firestoreService.fetchSettings();
      _classes = await _firestoreService.fetchClasses();
      _students = await _firestoreService.fetchStudents();
      _payments = await _firestoreService.fetchPayments();
      _staffList = await _firestoreService.fetchStaff();
      _notices = await _firestoreService.fetchNotices();
      _gallery = await _firestoreService.fetchGallery();
      _academicYears = await _firestoreService.fetchAcademicYears();
      _studentGroups = await _firestoreService.fetchStudentGroups();
      _concessions = await _firestoreService.fetchConcessions();
      _customFeeItems = await _firestoreService.fetchCustomFees();
      _auditLogs = await _firestoreService.fetchAuditLogs();

      if (_classes.isEmpty) {
        // Derive classes dynamically from students in Firestore
        final studentClasses = _students
            .map((s) => s.studentClass.trim())
            .where((c) => c.isNotEmpty && c.toLowerCase() != 'alumni')
            .toSet()
            .toList();
        studentClasses.sort();

        if (studentClasses.isNotEmpty) {
          _classes = studentClasses;
        } else {
          _classes = [
            'Class 1',
            'Class 2',
            'Class 3',
            'Class 4',
            'Class 5',
            'Class 6',
            'Class 7',
            'Class 8',
            'Class 9',
            'Class 10',
            'Class 11',
            'Class 12',
          ];
        }
      }
    } catch (e) {
      debugPrint('[InstitutionProvider] init error: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // ==================== SETTINGS & CLASSES ====================
  Future<void> updateSettings(InstitutionSetting newSetting) async {
    _setting = newSetting;
    notifyListeners();
    await _firestoreService.saveSettings(newSetting);
  }

  Future<void> addClass(String className) async {
    final clean = className.trim();
    if (clean.isEmpty || _classes.contains(clean)) return;
    _classes.add(clean);
    notifyListeners();
    await _firestoreService.saveClasses(_classes);
  }

  Future<void> removeClass(String className) async {
    _classes.remove(className);
    notifyListeners();
    await _firestoreService.saveClasses(_classes);
  }

  Future<void> generateDefaultClasses() async {
    _classes = [
      'Class 1', 'Class 2', 'Class 3', 'Class 4',
      'Class 5', 'Class 6', 'Class 7', 'Class 8',
      'Class 9', 'Class 10', 'Class 11', 'Class 12',
    ];
    notifyListeners();
    await _firestoreService.saveClasses(_classes);
    await addAuditLog('class', 'GENERATE_CLASSES', 'Generated default classes 1 through 12');
  }

  Future<void> generateDivisions(String baseClass, int count) async {
    final cleanBase = baseClass.trim();
    if (cleanBase.isEmpty || count < 1) return;
    final divisions = ['A', 'B', 'C', 'D', 'E', 'F', 'G', 'H', 'I', 'J'];
    for (int i = 0; i < count && i < divisions.length; i++) {
      final divName = '$cleanBase ${divisions[i]}';
      if (!_classes.contains(divName)) {
        _classes.add(divName);
      }
    }
    _classes.sort();
    notifyListeners();
    await _firestoreService.saveClasses(_classes);
    await addAuditLog('class', 'GENERATE_DIVISIONS', 'Generated $count divisions for $cleanBase');
  }

  Future<void> renameClass(String oldName, String newName) async {
    final cleanOld = oldName.trim();
    final cleanNew = newName.trim();
    if (cleanNew.isEmpty || cleanOld == cleanNew) return;

    final idx = _classes.indexOf(cleanOld);
    if (idx != -1) {
      _classes[idx] = cleanNew;
      // Also update all students in that class
      for (int i = 0; i < _students.length; i++) {
        if (_students[i].studentClass == cleanOld) {
          final updated = _students[i].copyWith(studentClass: cleanNew);
          _students[i] = updated;
          _firestoreService.saveStudent(updated);
        }
      }
      notifyListeners();
      await _firestoreService.saveClasses(_classes);
      await addAuditLog('class', 'RENAME_CLASS', 'Renamed class $cleanOld to $cleanNew');
    }
  }

  Future<void> moveStudentsToClass(List<String> studentIds, String targetClass) async {
    final cleanTarget = targetClass.trim();
    if (cleanTarget.isEmpty || studentIds.isEmpty) return;

    for (final sid in studentIds) {
      final idx = _students.indexWhere((s) => s.id == sid);
      if (idx != -1) {
        final updated = _students[idx].copyWith(studentClass: cleanTarget);
        _students[idx] = updated;
        await _firestoreService.saveStudent(updated);
      }
    }
    notifyListeners();
    await addAuditLog('class', 'MOVE_STUDENTS', 'Moved ${studentIds.length} students to $cleanTarget');
  }

  // ==================== NOTICES ====================
  Future<void> saveNotice(Notice notice) async {
    await _firestoreService.saveNotice(notice);
    _notices = await _firestoreService.fetchNotices();
    notifyListeners();
    await addAuditLog('website', 'SAVE_NOTICE', 'Notice "${notice.heading}" saved');
  }

  Future<void> deleteNotice(String id) async {
    await _firestoreService.deleteNotice(id);
    _notices = await _firestoreService.fetchNotices();
    notifyListeners();
    await addAuditLog('website', 'DELETE_NOTICE', 'Notice deleted');
  }

  // ==================== GALLERY ====================
  Future<void> saveGalleryItem(GalleryItem item) async {
    await _firestoreService.saveGalleryItem(item);
    _gallery = await _firestoreService.fetchGallery();
    notifyListeners();
    await addAuditLog('website', 'SAVE_GALLERY', 'Gallery photo saved');
  }

  Future<void> addGalleryItem(GalleryItem item) async {
    await saveGalleryItem(item);
  }

  Future<void> deleteGalleryItem(String id) async {
    await _firestoreService.deleteGalleryItem(id);
    _gallery = await _firestoreService.fetchGallery();
    notifyListeners();
    await addAuditLog('website', 'DELETE_GALLERY', 'Gallery photo deleted');
  }

  // ==================== ACADEMIC YEARS ====================
  Future<void> addAcademicYear(AcademicYearConfig config) async {
    _academicYears.removeWhere((y) => y.label == config.label);
    _academicYears.insert(0, config);
    notifyListeners();
    await _firestoreService.saveAcademicYears(_academicYears);
    await addAuditLog('class', 'ADD_YEAR', 'Added academic year ${config.label}');
  }

  Future<void> setWorkingAcademicYear(String yearLabel) async {
    final updated = _setting.copyWith(activeAcademicYear: yearLabel);
    await updateSettings(updated);
    for (int i = 0; i < _academicYears.length; i++) {
      if (_academicYears[i].label == yearLabel) {
        _academicYears[i] = AcademicYearConfig(
          label: _academicYears[i].label,
          startMonth: _academicYears[i].startMonth,
          endMonth: _academicYears[i].endMonth,
          status: 'current',
        );
      } else if (_academicYears[i].status == 'current') {
        _academicYears[i] = AcademicYearConfig(
          label: _academicYears[i].label,
          startMonth: _academicYears[i].startMonth,
          endMonth: _academicYears[i].endMonth,
          status: 'active',
        );
      }
    }
    notifyListeners();
    await _firestoreService.saveAcademicYears(_academicYears);
    await addAuditLog('class', 'SET_ACTIVE_YEAR', 'Set active academic year to $yearLabel');
  }

  Future<void> deleteAcademicYear(String yearLabel) async {
    _academicYears.removeWhere((y) => y.label == yearLabel);
    notifyListeners();
    await _firestoreService.saveAcademicYears(_academicYears);
    await addAuditLog('class', 'DELETE_YEAR', 'Deleted academic year $yearLabel');
  }

  // ==================== STUDENT SIBLING GROUPS ====================
  Future<void> saveStudentGroup(StudentGroup group) async {
    await _firestoreService.saveStudentGroup(group);
    _studentGroups = await _firestoreService.fetchStudentGroups();
    notifyListeners();
    await addAuditLog('group', 'SAVE_GROUP', 'Group "${group.name}" saved with ${group.memberStudentIds.length} members');
  }

  Future<void> deleteStudentGroup(String id) async {
    await _firestoreService.deleteStudentGroup(id);
    _studentGroups = await _firestoreService.fetchStudentGroups();
    notifyListeners();
    await addAuditLog('group', 'DELETE_GROUP', 'Deleted group #$id');
  }

  Future<void> unifyFamilyDetails(String primaryStudentId, List<String> memberIds) async {
    final primary = _students.firstWhere((s) => s.id == primaryStudentId);
    for (final mid in memberIds) {
      if (mid == primaryStudentId) continue;
      final idx = _students.indexWhere((s) => s.id == mid);
      if (idx != -1) {
        final unified = _students[idx].copyWith(
          father: primary.father,
          mother: primary.mother,
          mobile: primary.mobile,
          motherMobile: primary.motherMobile,
          address: primary.address,
        );
        _students[idx] = unified;
        await _firestoreService.saveStudent(unified);
      }
    }
    notifyListeners();
    await addAuditLog('group', 'UNIFY_FAMILY', 'Unified family details for ${memberIds.length} members matching ${primary.name}');
  }

  // ==================== FEE CONCESSIONS ====================
  Future<void> saveConcession(FeeConcession concession) async {
    await _firestoreService.saveConcession(concession);
    _concessions = await _firestoreService.fetchConcessions();
    notifyListeners();
    await addAuditLog('fee', 'SAVE_CONCESSION', 'Set ₹${concession.concessionMonthlyFee} concession for ${concession.studentName}');
  }

  Future<void> removeConcession(String studentId) async {
    await _firestoreService.deleteConcession(studentId);
    _concessions = await _firestoreService.fetchConcessions();
    notifyListeners();
    await addAuditLog('fee', 'DELETE_CONCESSION', 'Removed concession for student #$studentId');
  }

  // ==================== CUSTOM FEE ITEMS ====================
  Future<void> saveCustomFeeItem(CustomFeeItem item) async {
    await _firestoreService.saveCustomFee(item);
    _customFeeItems = await _firestoreService.fetchCustomFees();
    notifyListeners();
    await addAuditLog('fee', 'SAVE_FEE_ITEM', 'Custom fee item "${item.name}" saved');
  }

  Future<void> deleteCustomFeeItem(String id) async {
    await _firestoreService.deleteCustomFee(id);
    _customFeeItems = await _firestoreService.fetchCustomFees();
    notifyListeners();
    await addAuditLog('fee', 'DELETE_FEE_ITEM', 'Deleted custom fee item #$id');
  }

  // ==================== AUDIT LOGS ====================
  Future<void> addAuditLog(String category, String action, String message) async {
    final entry = AuditLogEntry(
      id: 'log_${DateTime.now().millisecondsSinceEpoch}',
      timestamp: DateTime.now().toIso8601String(),
      category: category,
      action: action,
      message: message,
      adminEmail: _currentStaff?.email ?? _setting.email,
    );
    await _firestoreService.addAuditLog(entry);
    _auditLogs = await _firestoreService.fetchAuditLogs();
    notifyListeners();
  }

  Future<void> clearAuditLogs() async {
    await _firestoreService.clearAuditLogs();
    _auditLogs.clear();
    notifyListeners();
  }

  // ==================== BACKUP & CREDENTIALS ====================
  Future<String> exportBackupJson() async {
    await addAuditLog('backup', 'EXPORT_BACKUP', 'Exported JSON backup snapshot');
    return await _firestoreService.exportDatabaseJson();
  }

  Future<Map<String, dynamic>> restoreBackupJson(String jsonString) async {
    final result = await _firestoreService.restoreDatabaseJson(jsonString);
    if (result['success'] == true) {
      await init();
      await addAuditLog('backup', 'RESTORE_BACKUP', 'Restored database from JSON: ${result['studentsRestored']} students, ${result['staffRestored']} staff');
    }
    return result;
  }

  // ==================== STAFF MANAGEMENT ====================
  Future<void> addStaff(Staff staff) async {
    _staffList.add(staff);
    notifyListeners();
    await _firestoreService.saveStaff(staff);
  }

  Future<void> updateStaff(Staff staff) async {
    final idx = _staffList.indexWhere((s) => s.id == staff.id);
    if (idx != -1) {
      _staffList[idx] = staff;
      notifyListeners();
      await _firestoreService.saveStaff(staff);
    }
  }

  Future<void> deleteStaff(String staffId) async {
    _staffList.removeWhere((s) => s.id == staffId);
    notifyListeners();
    await _firestoreService.deleteStaff(staffId);
  }

  // ==================== STUDENTS ====================
  /// Add student with strict duplicate admission prevention
  Future<String?> addStudent(Student student) async {
    // 1. Admission Number Uniqueness check
    if (DuplicateGuard.isAdmissionNoDuplicate(student.adm, _students)) {
      return 'Duplicate Admission Number! #${student.adm} is already assigned.';
    }

    // 2. Exact match check
    final candidate = DuplicateGuard.findDuplicateCandidate(
      student.name,
      student.studentClass,
      student.father,
      student.mobile,
      _students,
    );
    if (candidate != null) {
      return 'Potential duplicate student: ${candidate.compoundIdentity} already exists!';
    }

    _isLoading = true;
    notifyListeners();

    try {
      final saved = await _firestoreService.saveStudent(student);
      _students.add(saved);
      return null;
    } catch (e) {
      return 'Failed to save student: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> updateStudent(Student student) async {
    final idx = _students.indexWhere((s) => s.id == student.id);
    if (idx != -1) {
      _students[idx] = student;
      notifyListeners();
      await _firestoreService.updateStudent(student);
    }
  }

  Future<void> deleteStudent(String studentId) async {
    _students.removeWhere((s) => s.id == studentId);
    notifyListeners();
    await _firestoreService.deleteStudent(studentId);
  }

  // ==================== CONTINUITY & ALUMNI ====================
  /// Discontinue student with frozen dues retention and settlement
  Future<void> discontinueStudent(
    Student student,
    String reason,
    String exitDate, {
    double frozenPendingDue = 0.0,
    Map<String, dynamic>? settlementDetails,
  }) async {
    final logEntry = {
      'action': 'DISCONTINUED',
      'date': exitDate,
      'reason': reason,
      'class': student.studentClass,
      'academicYear': student.academicYear,
      'frozenDue': frozenPendingDue,
      if (settlementDetails != null) 'settlement': settlementDetails,
    };

    final updated = student.copyWith(
      status: 'Discontinued',
      exitReason: reason,
      exitDate: exitDate,
      frozenPendingDue: frozenPendingDue,
      continuityLog: [
        ...student.continuityLog,
        logEntry,
      ],
    );
    await updateStudent(updated);
    await addAuditLog('student', 'DISCONTINUE_STUDENT', 'Discontinued ${student.name} (#${student.adm}) with frozen due: ₹$frozenPendingDue');
  }

  /// Re-admit student after gap years with zero gap fee guarantee and dues strategy
  Future<void> readmitStudent(
    Student student,
    String targetClass,
    String targetYear,
    String reason, {
    int? newRoll,
    String? returnDate,
    double restoredDues = 0.0,
    String duesStrategy = 'carry_forward',
  }) async {
    final retDate = returnDate ?? DateTime.now().toString().split(' ')[0];
    final logEntry = {
      'action': 'READMITTED',
      'date': retDate,
      'targetClass': targetClass,
      'targetYear': targetYear,
      'notes': reason,
      'duesStrategy': duesStrategy,
      'restoredDues': restoredDues,
    };

    final updated = student.copyWith(
      status: 'Active',
      studentClass: targetClass,
      academicYear: targetYear,
      roll: newRoll ?? student.roll,
      returnDate: retDate,
      frozenPendingDue: duesStrategy == 'waive' ? 0.0 : (duesStrategy == 'settle_now' ? 0.0 : restoredDues),
      continuityLog: [
        ...student.continuityLog,
        logEntry,
      ],
    );
    await updateStudent(updated);
    await addAuditLog('student', 'READMIT_STUDENT', 'Re-admitted ${student.name} (#${student.adm}) to $targetClass ($targetYear)');
  }

  /// Settle preserved dues for a departed student
  Future<void> settleDepartedStudentDues(
    Student student,
    double amount,
    String receiptNo,
    String paymentMode,
  ) async {
    final remainingDue = (student.frozenPendingDue - amount).clamp(0.0, double.infinity);
    final logEntry = {
      'action': 'DEPARTED_DUE_SETTLED',
      'date': DateTime.now().toString().split(' ')[0],
      'amount': amount,
      'receiptNo': receiptNo,
      'mode': paymentMode,
      'remainingDue': remainingDue,
    };

    final updated = student.copyWith(
      frozenPendingDue: remainingDue,
      continuityLog: [
        ...student.continuityLog,
        logEntry,
      ],
    );
    await updateStudent(updated);

    final payment = Payment(
      id: 'pay_${DateTime.now().millisecondsSinceEpoch}',
      paymentId: 'pay_${DateTime.now().millisecondsSinceEpoch}',
      receiptNo: int.tryParse(receiptNo) ?? 1001,
      studentId: student.id,
      admissionNo: student.adm,
      studentName: student.name,
      studentClass: student.studentClass,
      academicYear: student.academicYear,
      amount: amount,
      paymentDate: DateTime.now().toString().split(' ')[0],
      paymentMode: paymentMode,
      feeItems: [
        FeeItemEntry(
          itemKey: 'DEPARTED_DUES',
          itemLabel: 'Departed Preserved Dues Settlement',
          amount: amount,
          period: 'Settlement',
          ledgerKey: '${student.id}_${student.academicYear}_DEPARTED_DUES',
        ),
      ],
      collectedByName: 'Admin Desk',
      status: 'VALID',
    );
    await collectPayment(payment);
    await addAuditLog('fee', 'DEPARTED_DUE_SETTLED', 'Settled ₹$amount for departed student ${student.name} (#${student.adm})');
  }

  /// Promote class students to next class or Alumni
  Future<void> promoteClass(String fromClass, String toClass, bool isFinalYear) async {
    final cohort = _students.where((s) => s.studentClass == fromClass && s.status == 'Active').toList();
    final currentYear = _setting.activeAcademicYear;

    for (final s in cohort) {
      if (isFinalYear || toClass == 'Alumni') {
        final alumni = s.copyWith(
          status: 'Alumni',
          studentClass: 'Alumni',
          graduatedYear: currentYear,
          completedClass: fromClass,
        );
        await updateStudent(alumni);
      } else {
        final promoted = s.copyWith(
          studentClass: toClass,
        );
        await updateStudent(promoted);
      }
    }
  }

  // ==================== PAYMENTS ====================
  Future<String?> collectPayment(Payment payment) async {
    // Verify that none of the fee items are already paid
    for (final item in payment.feeItems) {
      final isPaid = DuplicateGuard.isFeeItemPaid(
        studentId: payment.studentId,
        academicYear: payment.academicYear,
        itemKey: item.itemKey,
        period: item.period,
        payments: _payments,
      );
      if (isPaid) {
        return 'Item "${item.itemLabel}" for period "${item.period}" is already paid for this student!';
      }
    }

    _isLoading = true;
    notifyListeners();

    try {
      final saved = await _firestoreService.recordPayment(payment);
      _payments.insert(0, saved);
      return null;
    } catch (e) {
      return 'Failed to record payment: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> voidPayment(String paymentId, {String reason = 'Cancelled by Administrator'}) async {
    final idx = _payments.indexWhere((p) => p.id == paymentId);
    if (idx != -1) {
      final p = _payments[idx];
      final voided = Payment(
        id: p.id,
        paymentId: p.paymentId,
        receiptNo: p.receiptNo,
        studentId: p.studentId,
        admissionNo: p.admissionNo,
        studentName: p.studentName,
        studentClass: p.studentClass,
        academicYear: p.academicYear,
        amount: p.amount,
        paymentDate: p.paymentDate,
        paymentMode: p.paymentMode,
        feeItems: p.feeItems,
        collectedByName: p.collectedByName,
        status: 'VOIDED',
      );
      _payments[idx] = voided;
      notifyListeners();
      await _firestoreService.updatePayment(voided);
    }
  }

  // ==================== EXAM RESULTS ====================
  Future<List<ExamResult>> loadExamResults(String examId, String studentClass) async {
    final results = await _firestoreService.fetchExamResults(examId, studentClass);
    _examResults = results;
    notifyListeners();
    return results;
  }

  Future<void> saveExamResult(ExamResult result) async {
    await _firestoreService.saveExamResult(result);
    final idx = _examResults.indexWhere((r) => r.id == result.id);
    if (idx != -1) {
      _examResults[idx] = result;
    } else {
      _examResults.add(result);
    }
    notifyListeners();
  }

  // ==================== AUTHENTICATION ====================
  /// Student Login: Match by Class + (AdmNo or exact Student Name) + Registered Mobile Phone
  Student? authenticateStudent(String studentClass, String admOrName, String phone) {
    final cleanCls = studentClass.trim().toLowerCase();
    final cleanId = admOrName.trim().toLowerCase();
    final cleanPhone = phone.replaceAll(RegExp(r'\D'), '').trim();

    for (final s in _students) {
      final sClass = s.studentClass.trim().toLowerCase();
      final sName = s.name.trim().toLowerCase();
      final sAdm = s.adm.trim().toLowerCase();
      final sPhone = s.mobile.replaceAll(RegExp(r'\D'), '').trim();

      final classMatches = cleanCls.isEmpty || sClass == cleanCls || (cleanCls == 'alumni' && s.status == 'Alumni');
      final idMatches = cleanId.isEmpty || sAdm == cleanId || sName.contains(cleanId);
      final phoneMatches = sPhone.isNotEmpty && sPhone == cleanPhone;

      if (classMatches && idMatches && phoneMatches) {
        _currentStudent = s;
        _currentRole = 'student';
        notifyListeners();
        return s;
      }
    }
    return null;
  }

  /// Official Staff Login
  Staff? authenticateStaff(String emailOrId, String password) {
    final cleanInput = emailOrId.trim().toLowerCase();

    // Default Super Admin bypass if no staff is yet registered (First Run)
    if (_staffList.isEmpty && (cleanInput == 'admin' || cleanInput == 'admin@institution.edu')) {
      final defaultAdmin = Staff(
        id: 'ADMIN_01',
        name: 'Super Administrator',
        role: 'ADMIN',
        designation: 'HEADMASTER',
        email: 'admin@institution.edu',
        hasAdminAccess: true,
        hasCollectionAccess: true,
        hasResultAccess: true,
        hasWorksheetAccess: true,
      );
      _currentStaff = defaultAdmin;
      _currentRole = 'super_admin';
      notifyListeners();
      return defaultAdmin;
    }

    for (final st in _staffList) {
      final stEmail = st.email.trim().toLowerCase();
      final stName = st.name.trim().toLowerCase();
      if (stEmail == cleanInput || stName == cleanInput || st.id == cleanInput) {
        _currentStaff = st;
        _currentRole = st.hasAdminAccess ? 'super_admin' : 'class_teacher';
        notifyListeners();
        return st;
      }
    }
    return null;
  }

  void loginStudent(Student student) {
    _currentStudent = student;
    _currentRole = 'student';
    notifyListeners();
  }

  Future<bool> loginStaff(String emailOrId, String password) async {
    final cleanInput = emailOrId.trim();

    // 1. First, attempt official Firebase Authentication via REST API
    if (cleanInput.contains('@')) {
      final authResult = await _firestoreService.signInWithFirebaseAuth(cleanInput, password);
      if (authResult != null && !authResult.containsKey('error')) {
        // Authenticated successfully via Firebase Auth
        final isAdmin = cleanInput.toLowerCase() == _setting.email.toLowerCase() ||
            cleanInput.toLowerCase() == 'nimdevathiyal4883@gmail.com';

        final adminStaff = Staff(
          id: authResult['localId']?.toString() ?? 'ADMIN_01',
          name: isAdmin ? 'Administrator' : cleanInput.split('@').first,
          role: isAdmin ? 'ADMIN' : 'STAFF',
          designation: isAdmin ? 'HEADMASTER' : 'STAFF',
          email: cleanInput,
          hasAdminAccess: true,
          hasCollectionAccess: true,
          hasResultAccess: true,
          hasWorksheetAccess: true,
        );
        _currentStaff = adminStaff;
        _currentRole = 'super_admin';
        notifyListeners();
        return true;
      }
    }

    // 2. Fallback to local staff list check
    return authenticateStaff(emailOrId, password) != null;
  }

  void logout() {
    _currentRole = null;
    _currentStudent = null;
    _currentStaff = null;
    notifyListeners();
  }
}
