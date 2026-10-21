import 'package:flutter/material.dart';
import '../models/institution_setting.dart';
import '../models/student.dart';
import '../models/payment.dart';
import '../models/staff.dart';
import '../models/exam_result.dart';
import '../services/firestore_service.dart';
import '../services/duplicate_guard.dart';

class InstitutionProvider extends ChangeNotifier {
  final FirestoreService _firestoreService = FirestoreService();

  bool _isLoading = false;
  bool get isLoading => _isLoading;

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

      if (_classes.isEmpty) {
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
  /// Discontinue student
  Future<void> discontinueStudent(Student student, String reason, String exitDate) async {
    final updated = student.copyWith(
      status: 'Discontinued',
      exitReason: reason,
      exitDate: exitDate,
      continuityLog: [
        ...student.continuityLog,
        {
          'action': 'DISCONTINUED',
          'date': exitDate,
          'reason': reason,
          'class': student.studentClass,
          'academicYear': student.academicYear,
        }
      ],
    );
    await updateStudent(updated);
  }

  /// Re-admit student after gap years
  Future<void> readmitStudent(Student student, String targetClass, String targetYear, String reason) async {
    final returnDate = DateTime.now().toString().split(' ')[0];
    final updated = student.copyWith(
      status: 'Active',
      studentClass: targetClass,
      academicYear: targetYear,
      returnDate: returnDate,
      continuityLog: [
        ...student.continuityLog,
        {
          'action': 'READMITTED',
          'date': returnDate,
          'targetClass': targetClass,
          'targetYear': targetYear,
          'notes': reason,
        }
      ],
    );
    await updateStudent(updated);
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
    return authenticateStaff(emailOrId, password) != null;
  }

  void logout() {
    _currentRole = null;
    _currentStudent = null;
    _currentStaff = null;
    notifyListeners();
  }
}
