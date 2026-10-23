import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../config/app_constants.dart';
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
import '../models/staff_category.dart';

/// Firebase Firestore Communication Service
class FirestoreService {
  final String baseUrl = AppConstants.firestoreBaseUrl;

  // Local state cache
  InstitutionSetting _cachedSetting = InstitutionSetting();
  List<String> _cachedClasses = [];
  final List<Student> _cachedStudents = [];
  final List<Payment> _cachedPayments = [];
  final List<Staff> _cachedStaff = [];
  final List<StaffCategory> _cachedStaffCategories = [];
  final List<ExamResult> _cachedResults = [];
  final List<Notice> _cachedNotices = [];
  final List<GalleryItem> _cachedGallery = [];
  final List<AcademicYearConfig> _cachedYears = [];
  final List<StudentGroup> _cachedGroups = [];
  final List<FeeConcession> _cachedConcessions = [];
  final List<CustomFeeItem> _cachedCustomFees = [];
  final List<AuditLogEntry> _cachedAuditLogs = [];

  // ==================== SETTINGS ====================
  Future<InstitutionSetting> fetchSettings() async {
    try {
      // Primary doc in user Firestore is settings/instituteConfig, fallback to settings/general
      var url = Uri.parse('$baseUrl/settings/instituteConfig');
      var res = await http.get(url);
      if (res.statusCode != 200) {
        url = Uri.parse('$baseUrl/settings/general');
        res = await http.get(url);
      }
      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        final fields = _decodeFirestoreFields(data['fields'] ?? {});
        _cachedSetting = InstitutionSetting.fromMap(fields);
        return _cachedSetting;
      }
    } catch (e) {
      debugPrint('[FirestoreService] fetchSettings notice: $e');
    }
    return _cachedSetting;
  }

  Future<bool> saveSettings(InstitutionSetting setting) async {
    _cachedSetting = setting;
    try {
      final url = Uri.parse('$baseUrl/settings/instituteConfig');
      final body = jsonEncode({
        'fields': _encodeFirestoreFields(setting.toMap()),
      });
      final res = await http.patch(url, body: body, headers: {'Content-Type': 'application/json'});
      return res.statusCode == 200;
    } catch (e) {
      debugPrint('[FirestoreService] saveSettings notice: $e');
      return true; // Local state saved
    }
  }

  // ==================== CLASSES ====================
  Future<List<String>> fetchClasses() async {
    try {
      final url = Uri.parse('$baseUrl/settings/classes');
      final res = await http.get(url);
      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        final fields = _decodeFirestoreFields(data['fields'] ?? {});
        if (fields['classList'] is List) {
          _cachedClasses = List<String>.from(fields['classList']);
          return _cachedClasses;
        }
      }
    } catch (e) {
      debugPrint('[FirestoreService] fetchClasses notice: $e');
    }
    return _cachedClasses;
  }

  Future<bool> saveClasses(List<String> classes) async {
    _cachedClasses = List.from(classes);
    try {
      final url = Uri.parse('$baseUrl/settings/classes');
      final body = jsonEncode({
        'fields': _encodeFirestoreFields({'classList': classes}),
      });
      final res = await http.patch(url, body: body, headers: {'Content-Type': 'application/json'});
      return res.statusCode == 200;
    } catch (e) {
      debugPrint('[FirestoreService] saveClasses notice: $e');
      return true;
    }
  }

  // ==================== STUDENTS ====================
  Future<List<Student>> fetchStudents() async {
    try {
      final url = Uri.parse('$baseUrl/students');
      final res = await http.get(url);
      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        final documents = data['documents'] as List?;
        if (documents != null) {
          _cachedStudents.clear();
          for (final doc in documents) {
            final docName = doc['name']?.toString() ?? '';
            final docId = docName.split('/').last;
            final fields = _decodeFirestoreFields(doc['fields'] ?? {});
            _cachedStudents.add(Student.fromMap(fields, docId));
          }
          return _cachedStudents;
        }
      }
    } catch (e) {
      debugPrint('[FirestoreService] fetchStudents notice: $e');
    }
    return _cachedStudents;
  }

  Future<Student> createStudent(Student student) async {
    final docId = 'ST_${DateTime.now().millisecondsSinceEpoch}';
    final newStudent = student.copyWith(id: docId);
    _cachedStudents.add(newStudent);

    try {
      final url = Uri.parse('$baseUrl/students?documentId=$docId');
      final body = jsonEncode({
        'fields': _encodeFirestoreFields(newStudent.toMap()),
      });
      await http.post(url, body: body, headers: {'Content-Type': 'application/json'});
    } catch (e) {
      debugPrint('[FirestoreService] createStudent notice: $e');
    }
    return newStudent;
  }

  Future<Student> saveStudent(Student student) => createStudent(student);

  Future<bool> updateStudent(Student student) async {
    final idx = _cachedStudents.indexWhere((s) => s.id == student.id);
    if (idx != -1) {
      _cachedStudents[idx] = student;
    }

    try {
      final url = Uri.parse('$baseUrl/students/${student.id}');
      final body = jsonEncode({
        'fields': _encodeFirestoreFields(student.toMap()),
      });
      final res = await http.patch(url, body: body, headers: {'Content-Type': 'application/json'});
      return res.statusCode == 200;
    } catch (e) {
      debugPrint('[FirestoreService] updateStudent notice: $e');
      return true;
    }
  }

  Future<bool> deleteStudent(String studentId) async {
    _cachedStudents.removeWhere((s) => s.id == studentId);
    try {
      final url = Uri.parse('$baseUrl/students/$studentId');
      final res = await http.delete(url);
      return res.statusCode == 200;
    } catch (e) {
      debugPrint('[FirestoreService] deleteStudent notice: $e');
      return true;
    }
  }

  // ==================== PAYMENTS ====================
  Future<List<Payment>> fetchPayments() async {
    try {
      final url = Uri.parse('$baseUrl/payments');
      final res = await http.get(url);
      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        final documents = data['documents'] as List?;
        if (documents != null) {
          _cachedPayments.clear();
          for (final doc in documents) {
            final docName = doc['name']?.toString() ?? '';
            final docId = docName.split('/').last;
            final fields = _decodeFirestoreFields(doc['fields'] ?? {});
            _cachedPayments.add(Payment.fromMap(fields, docId));
          }
          return _cachedPayments;
        }
      }
    } catch (e) {
      debugPrint('[FirestoreService] fetchPayments notice: $e');
    }
    return _cachedPayments;
  }

  Future<Payment> recordPayment(Payment payment) async {
    final docId = 'PAY_${payment.receiptNo}_${DateTime.now().millisecondsSinceEpoch}';
    final savedPayment = Payment(
      id: docId,
      paymentId: docId,
      receiptNo: payment.receiptNo,
      studentId: payment.studentId,
      admissionNo: payment.admissionNo,
      studentName: payment.studentName,
      studentClass: payment.studentClass,
      academicYear: payment.academicYear,
      amount: payment.amount,
      paymentDate: payment.paymentDate,
      paymentMode: paymentModeToString(payment.paymentMode),
      feeItems: payment.feeItems,
      collectedByName: payment.collectedByName,
      status: 'VALID',
    );
    _cachedPayments.insert(0, savedPayment);

    try {
      final url = Uri.parse('$baseUrl/payments?documentId=$docId');
      final body = jsonEncode({
        'fields': _encodeFirestoreFields(savedPayment.toMap()),
      });
      await http.post(url, body: body, headers: {'Content-Type': 'application/json'});
    } catch (e) {
      debugPrint('[FirestoreService] recordPayment notice: $e');
    }
    return savedPayment;
  }

  static String paymentModeToString(dynamic mode) => mode.toString();

  Future<bool> updatePayment(Payment payment) async {
    final idx = _cachedPayments.indexWhere((p) => p.id == payment.id);
    if (idx != -1) {
      _cachedPayments[idx] = payment;
    }
    try {
      final url = Uri.parse('$baseUrl/payments/${payment.id}');
      final body = jsonEncode({
        'fields': _encodeFirestoreFields(payment.toMap()),
      });
      final res = await http.patch(url, body: body, headers: {'Content-Type': 'application/json'});
      return res.statusCode == 200;
    } catch (e) {
      debugPrint('[FirestoreService] updatePayment notice: $e');
      return true;
    }
  }

  // ==================== STAFF ====================
  Future<List<Staff>> fetchStaff() async {
    try {
      final url = Uri.parse('$baseUrl/staff');
      final res = await http.get(url);
      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        final documents = data['documents'] as List?;
        if (documents != null) {
          _cachedStaff.clear();
          for (final doc in documents) {
            final docName = doc['name']?.toString() ?? '';
            final docId = docName.split('/').last;
            final fields = _decodeFirestoreFields(doc['fields'] ?? {});
            _cachedStaff.add(Staff.fromMap(fields, docId));
          }
          return _cachedStaff;
        }
      }
    } catch (e) {
      debugPrint('[FirestoreService] fetchStaff notice: $e');
    }
    return _cachedStaff;
  }

  Future<Staff> createStaff(Staff staff) async {
    final docId = staff.id.isNotEmpty ? staff.id : 'STF_${DateTime.now().millisecondsSinceEpoch}';
    final newStaff = staff.copyWith(id: docId);
    _cachedStaff.add(newStaff);

    try {
      final url = Uri.parse('$baseUrl/staff?documentId=$docId');
      final body = jsonEncode({
        'fields': _encodeFirestoreFields(newStaff.toMap()),
      });
      await http.post(url, body: body, headers: {'Content-Type': 'application/json'});
    } catch (e) {
      debugPrint('[FirestoreService] createStaff notice: $e');
    }
    return newStaff;
  }

  Future<bool> saveStaff(Staff staff) async {
    final idx = _cachedStaff.indexWhere((s) => s.id == staff.id);
    if (idx != -1) {
      _cachedStaff[idx] = staff;
    } else {
      _cachedStaff.add(staff);
    }
    try {
      final url = Uri.parse('$baseUrl/staff/${staff.id}');
      final body = jsonEncode({
        'fields': _encodeFirestoreFields(staff.toMap()),
      });
      final res = await http.patch(url, body: body, headers: {'Content-Type': 'application/json'});
      return res.statusCode == 200;
    } catch (e) {
      debugPrint('[FirestoreService] saveStaff notice: $e');
      return true;
    }
  }

  Future<bool> deleteStaff(String staffId) async {
    _cachedStaff.removeWhere((s) => s.id == staffId);
    try {
      final url = Uri.parse('$baseUrl/staff/$staffId');
      final res = await http.delete(url);
      return res.statusCode == 200;
    } catch (e) {
      debugPrint('[FirestoreService] deleteStaff notice: $e');
      return true;
    }
  }

  // ==================== STAFF CATEGORIES ====================
  Future<List<StaffCategory>> fetchStaffCategories() async {
    if (_cachedStaffCategories.isNotEmpty) return _cachedStaffCategories;
    try {
      final url = Uri.parse('$baseUrl/settings/directoryCategories');
      final res = await http.get(url);
      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        final fields = _decodeFirestoreFields(data['fields'] ?? {});
        final raw = fields['categories'] ?? fields['list'];
        if (raw is List) {
          _cachedStaffCategories.clear();
          for (final item in raw) {
            if (item is Map<String, dynamic>) {
              _cachedStaffCategories.add(StaffCategory.fromMap(item));
            }
          }
        }
      }
    } catch (e) {
      debugPrint('[FirestoreService] fetchStaffCategories notice: $e');
    }

    if (_cachedStaffCategories.isEmpty) {
      _cachedStaffCategories.addAll([
        StaffCategory(id: 'Teacher', name: 'Teacher', order: 1, showPublic: true, isCore: true),
        StaffCategory(id: 'Management', name: 'Management', order: 2, showPublic: true, isCore: true),
      ]);
    }
    return _cachedStaffCategories;
  }

  Future<bool> saveStaffCategories(List<StaffCategory> categories) async {
    _cachedStaffCategories
      ..clear()
      ..addAll(categories);
    try {
      final url = Uri.parse('$baseUrl/settings/directoryCategories');
      final listMaps = categories.map((c) => c.toMap()).toList();
      final body = jsonEncode({
        'fields': _encodeFirestoreFields({'categories': listMaps}),
      });
      final res = await http.patch(url, body: body, headers: {'Content-Type': 'application/json'});
      return res.statusCode == 200;
    } catch (e) {
      debugPrint('[FirestoreService] saveStaffCategories notice: $e');
      return true;
    }
  }

  // ==================== EXAM RESULTS ====================
  Future<List<ExamResult>> fetchExamResults(String examId, String studentClass) async {
    try {
      final url = Uri.parse('$baseUrl/examResults');
      final res = await http.get(url);
      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        final documents = data['documents'] as List?;
        if (documents != null) {
          _cachedResults.clear();
          for (final doc in documents) {
            final docName = doc['name']?.toString() ?? '';
            final docId = docName.split('/').last;
            final fields = _decodeFirestoreFields(doc['fields'] ?? {});
            _cachedResults.add(ExamResult.fromMap(fields, docId));
          }
        }
      }
    } catch (e) {
      debugPrint('[FirestoreService] fetchExamResults notice: $e');
    }
    return _cachedResults
        .where((r) =>
            (examId.isEmpty || r.examId == examId) &&
            (studentClass.isEmpty || r.studentClass == studentClass))
        .toList();
  }

  Future<bool> saveExamResult(ExamResult result) async {
    // Unique composite key: examId_studentId
    final docId = '${result.examId}_${result.studentId}'.replaceAll(RegExp(r'[^\w-]'), '_');
    final idx = _cachedResults.indexWhere((r) => r.id == docId);
    if (idx != -1) {
      _cachedResults[idx] = result;
    } else {
      _cachedResults.add(result);
    }

    try {
      final url = Uri.parse('$baseUrl/examResults/$docId');
      final body = jsonEncode({
        'fields': _encodeFirestoreFields(result.toMap()),
      });
      final res = await http.patch(url, body: body, headers: {'Content-Type': 'application/json'});
      return res.statusCode == 200;
    } catch (e) {
      debugPrint('[FirestoreService] saveExamResult notice: $e');
      return true;
    }
  }

  // ==================== FIREBASE AUTH ====================
  Future<Map<String, dynamic>?> signInWithFirebaseAuth(String email, String password) async {
    try {
      final url = Uri.parse(AppConstants.firebaseAuthSignInUrl);
      final body = jsonEncode({
        'email': email,
        'password': password,
        'returnSecureToken': true,
      });
      final res = await http.post(url, body: body, headers: {'Content-Type': 'application/json'});
      if (res.statusCode == 200) {
        return jsonDecode(res.body) as Map<String, dynamic>;
      } else {
        final err = jsonDecode(res.body);
        final msg = err['error']?['message']?.toString() ?? 'Authentication failed';
        debugPrint('[FirestoreService] signInWithFirebaseAuth error: $msg');
        return {'error': msg};
      }
    } catch (e) {
      debugPrint('[FirestoreService] signInWithFirebaseAuth exception: $e');
      return {'error': e.toString()};
    }
  }

  // ==================== NOTICES ====================
  Future<List<Notice>> fetchNotices() async {
    try {
      final url = Uri.parse('$baseUrl/notices');
      final res = await http.get(url);
      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        final documents = data['documents'] as List? ?? [];
        _cachedNotices.clear();
        for (final doc in documents) {
          final docName = doc['name']?.toString() ?? '';
          final docId = docName.split('/').last;
          final fields = _decodeFirestoreFields(doc['fields'] ?? {});
          _cachedNotices.add(Notice.fromMap(docId, fields));
        }
      }
    } catch (e) {
      debugPrint('[FirestoreService] fetchNotices notice: $e');
    }
    return _cachedNotices;
  }

  Future<bool> saveNotice(Notice notice) async {
    final docId = notice.id.isEmpty ? 'not_${DateTime.now().millisecondsSinceEpoch}' : notice.id;
    final updated = Notice(
      id: docId,
      heading: notice.heading,
      description: notice.description,
      imageUrl: notice.imageUrl,
      date: notice.date,
      isPinned: notice.isPinned,
    );
    final idx = _cachedNotices.indexWhere((n) => n.id == docId);
    if (idx != -1) {
      _cachedNotices[idx] = updated;
    } else {
      _cachedNotices.insert(0, updated);
    }

    try {
      final url = Uri.parse('$baseUrl/notices/$docId');
      final body = jsonEncode({'fields': _encodeFirestoreFields(updated.toMap())});
      final res = await http.patch(url, body: body, headers: {'Content-Type': 'application/json'});
      return res.statusCode == 200;
    } catch (e) {
      debugPrint('[FirestoreService] saveNotice notice: $e');
      return true;
    }
  }

  Future<bool> deleteNotice(String id) async {
    _cachedNotices.removeWhere((n) => n.id == id);
    try {
      final url = Uri.parse('$baseUrl/notices/$id');
      final res = await http.delete(url);
      return res.statusCode == 200;
    } catch (e) {
      debugPrint('[FirestoreService] deleteNotice notice: $e');
      return true;
    }
  }

  // ==================== GALLERY ====================
  Future<List<GalleryItem>> fetchGallery() async {
    try {
      final url = Uri.parse('$baseUrl/gallery');
      final res = await http.get(url);
      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        final documents = data['documents'] as List? ?? [];
        _cachedGallery.clear();
        for (final doc in documents) {
          final docName = doc['name']?.toString() ?? '';
          final docId = docName.split('/').last;
          final fields = _decodeFirestoreFields(doc['fields'] ?? {});
          _cachedGallery.add(GalleryItem.fromMap(docId, fields));
        }
      }
    } catch (e) {
      debugPrint('[FirestoreService] fetchGallery notice: $e');
    }
    return _cachedGallery;
  }

  Future<bool> saveGalleryItem(GalleryItem item) async {
    final docId = item.id.isEmpty ? 'gal_${DateTime.now().millisecondsSinceEpoch}' : item.id;
    final updated = GalleryItem(
      id: docId,
      imageUrl: item.imageUrl,
      title: item.title,
      displayOrder: item.displayOrder,
    );
    final idx = _cachedGallery.indexWhere((g) => g.id == docId);
    if (idx != -1) {
      _cachedGallery[idx] = updated;
    } else {
      _cachedGallery.add(updated);
    }

    try {
      final url = Uri.parse('$baseUrl/gallery/$docId');
      final body = jsonEncode({'fields': _encodeFirestoreFields(updated.toMap())});
      final res = await http.patch(url, body: body, headers: {'Content-Type': 'application/json'});
      return res.statusCode == 200;
    } catch (e) {
      debugPrint('[FirestoreService] saveGalleryItem notice: $e');
      return true;
    }
  }

  Future<bool> deleteGalleryItem(String id) async {
    _cachedGallery.removeWhere((g) => g.id == id);
    try {
      final url = Uri.parse('$baseUrl/gallery/$id');
      final res = await http.delete(url);
      return res.statusCode == 200;
    } catch (e) {
      debugPrint('[FirestoreService] deleteGalleryItem notice: $e');
      return true;
    }
  }

  // ==================== ACADEMIC YEARS ====================
  Future<List<AcademicYearConfig>> fetchAcademicYears() async {
    try {
      final url = Uri.parse('$baseUrl/settings/academicYears');
      final res = await http.get(url);
      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        final fields = _decodeFirestoreFields(data['fields'] ?? {});
        if (fields['yearsList'] is List) {
          _cachedYears.clear();
          for (final y in fields['yearsList']) {
            if (y is Map<String, dynamic>) {
              _cachedYears.add(AcademicYearConfig.fromMap(y));
            } else if (y is String) {
              _cachedYears.add(AcademicYearConfig(label: y));
            }
          }
          return _cachedYears;
        }
      }
    } catch (e) {
      debugPrint('[FirestoreService] fetchAcademicYears notice: $e');
    }
    if (_cachedYears.isEmpty) {
      _cachedYears.addAll([
        AcademicYearConfig(label: '2026-2027', status: 'current'),
        AcademicYearConfig(label: '2025-2026', status: 'active'),
        AcademicYearConfig(label: '2024-2025', status: 'archived'),
      ]);
    }
    return _cachedYears;
  }

  Future<bool> saveAcademicYears(List<AcademicYearConfig> years) async {
    _cachedYears.clear();
    _cachedYears.addAll(years);
    try {
      final url = Uri.parse('$baseUrl/settings/academicYears');
      final rawList = years.map((y) => y.toMap()).toList();
      final body = jsonEncode({'fields': _encodeFirestoreFields({'yearsList': rawList})});
      final res = await http.patch(url, body: body, headers: {'Content-Type': 'application/json'});
      return res.statusCode == 200;
    } catch (e) {
      debugPrint('[FirestoreService] saveAcademicYears notice: $e');
      return true;
    }
  }

  // ==================== STUDENT GROUPS ====================
  Future<List<StudentGroup>> fetchStudentGroups() async {
    try {
      final url = Uri.parse('$baseUrl/studentGroups');
      final res = await http.get(url);
      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        final documents = data['documents'] as List? ?? [];
        _cachedGroups.clear();
        for (final doc in documents) {
          final docName = doc['name']?.toString() ?? '';
          final docId = docName.split('/').last;
          final fields = _decodeFirestoreFields(doc['fields'] ?? {});
          _cachedGroups.add(StudentGroup.fromMap(docId, fields));
        }
      }
    } catch (e) {
      debugPrint('[FirestoreService] fetchStudentGroups notice: $e');
    }
    return _cachedGroups;
  }

  Future<bool> saveStudentGroup(StudentGroup group) async {
    final docId = group.id.isEmpty ? 'grp_${DateTime.now().millisecondsSinceEpoch}' : group.id;
    final updated = StudentGroup(id: docId, name: group.name, monthlyFee: group.monthlyFee, memberStudentIds: group.memberStudentIds);
    final idx = _cachedGroups.indexWhere((g) => g.id == docId);
    if (idx != -1) {
      _cachedGroups[idx] = updated;
    } else {
      _cachedGroups.add(updated);
    }

    try {
      final url = Uri.parse('$baseUrl/studentGroups/$docId');
      final body = jsonEncode({'fields': _encodeFirestoreFields(updated.toMap())});
      final res = await http.patch(url, body: body, headers: {'Content-Type': 'application/json'});
      return res.statusCode == 200;
    } catch (e) {
      debugPrint('[FirestoreService] saveStudentGroup notice: $e');
      return true;
    }
  }

  Future<bool> deleteStudentGroup(String id) async {
    _cachedGroups.removeWhere((g) => g.id == id);
    try {
      final url = Uri.parse('$baseUrl/studentGroups/$id');
      final res = await http.delete(url);
      return res.statusCode == 200;
    } catch (e) {
      debugPrint('[FirestoreService] deleteStudentGroup notice: $e');
      return true;
    }
  }

  // ==================== FEE CONCESSIONS ====================
  Future<List<FeeConcession>> fetchConcessions() async {
    try {
      final url = Uri.parse('$baseUrl/concessions');
      final res = await http.get(url);
      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        final documents = data['documents'] as List? ?? [];
        _cachedConcessions.clear();
        for (final doc in documents) {
          final docName = doc['name']?.toString() ?? '';
          final docId = docName.split('/').last;
          final fields = _decodeFirestoreFields(doc['fields'] ?? {});
          _cachedConcessions.add(FeeConcession.fromMap(docId, fields));
        }
      }
    } catch (e) {
      debugPrint('[FirestoreService] fetchConcessions notice: $e');
    }
    return _cachedConcessions;
  }

  Future<bool> saveConcession(FeeConcession conc) async {
    final docId = conc.studentId;
    final idx = _cachedConcessions.indexWhere((c) => c.studentId == docId);
    if (idx != -1) {
      _cachedConcessions[idx] = conc;
    } else {
      _cachedConcessions.add(conc);
    }

    try {
      final url = Uri.parse('$baseUrl/concessions/$docId');
      final body = jsonEncode({'fields': _encodeFirestoreFields(conc.toMap())});
      final res = await http.patch(url, body: body, headers: {'Content-Type': 'application/json'});
      return res.statusCode == 200;
    } catch (e) {
      debugPrint('[FirestoreService] saveConcession notice: $e');
      return true;
    }
  }

  Future<bool> deleteConcession(String studentId) async {
    _cachedConcessions.removeWhere((c) => c.studentId == studentId);
    try {
      final url = Uri.parse('$baseUrl/concessions/$studentId');
      final res = await http.delete(url);
      return res.statusCode == 200;
    } catch (e) {
      debugPrint('[FirestoreService] deleteConcession notice: $e');
      return true;
    }
  }

  // ==================== CUSTOM FEE ITEMS ====================
  Future<List<CustomFeeItem>> fetchCustomFees() async {
    try {
      final url = Uri.parse('$baseUrl/customFeeItems');
      final res = await http.get(url);
      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        final documents = data['documents'] as List? ?? [];
        _cachedCustomFees.clear();
        for (final doc in documents) {
          final docName = doc['name']?.toString() ?? '';
          final docId = docName.split('/').last;
          final fields = _decodeFirestoreFields(doc['fields'] ?? {});
          _cachedCustomFees.add(CustomFeeItem.fromMap(docId, fields));
        }
      }
    } catch (e) {
      debugPrint('[FirestoreService] fetchCustomFees notice: $e');
    }
    return _cachedCustomFees;
  }

  Future<bool> saveCustomFee(CustomFeeItem fee) async {
    final docId = fee.id.isEmpty ? 'fee_${DateTime.now().millisecondsSinceEpoch}' : fee.id;
    final updated = CustomFeeItem(
      id: docId,
      name: fee.name,
      scope: fee.scope,
      globalAmount: fee.globalAmount,
      classWiseAmounts: fee.classWiseAmounts,
      specificClass: fee.specificClass,
      isReceiptRequired: fee.isReceiptRequired,
    );
    final idx = _cachedCustomFees.indexWhere((f) => f.id == docId);
    if (idx != -1) {
      _cachedCustomFees[idx] = updated;
    } else {
      _cachedCustomFees.add(updated);
    }

    try {
      final url = Uri.parse('$baseUrl/customFeeItems/$docId');
      final body = jsonEncode({'fields': _encodeFirestoreFields(updated.toMap())});
      final res = await http.patch(url, body: body, headers: {'Content-Type': 'application/json'});
      return res.statusCode == 200;
    } catch (e) {
      debugPrint('[FirestoreService] saveCustomFee notice: $e');
      return true;
    }
  }

  Future<bool> deleteCustomFee(String id) async {
    _cachedCustomFees.removeWhere((f) => f.id == id);
    try {
      final url = Uri.parse('$baseUrl/customFeeItems/$id');
      final res = await http.delete(url);
      return res.statusCode == 200;
    } catch (e) {
      debugPrint('[FirestoreService] deleteCustomFee notice: $e');
      return true;
    }
  }

  // ==================== SYSTEM AUDIT LOGS ====================
  Future<List<AuditLogEntry>> fetchAuditLogs() async {
    try {
      final url = Uri.parse('$baseUrl/auditLogs');
      final res = await http.get(url);
      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        final documents = data['documents'] as List? ?? [];
        _cachedAuditLogs.clear();
        for (final doc in documents) {
          final docName = doc['name']?.toString() ?? '';
          final docId = docName.split('/').last;
          final fields = _decodeFirestoreFields(doc['fields'] ?? {});
          _cachedAuditLogs.add(AuditLogEntry.fromMap(docId, fields));
        }
        _cachedAuditLogs.sort((a, b) => b.timestamp.compareTo(a.timestamp));
      }
    } catch (e) {
      debugPrint('[FirestoreService] fetchAuditLogs notice: $e');
    }
    return _cachedAuditLogs;
  }

  Future<bool> addAuditLog(AuditLogEntry entry) async {
    _cachedAuditLogs.insert(0, entry);
    try {
      final docId = entry.id.isEmpty ? 'log_${DateTime.now().millisecondsSinceEpoch}' : entry.id;
      final url = Uri.parse('$baseUrl/auditLogs/$docId');
      final body = jsonEncode({'fields': _encodeFirestoreFields(entry.toMap())});
      final res = await http.patch(url, body: body, headers: {'Content-Type': 'application/json'});
      return res.statusCode == 200;
    } catch (e) {
      debugPrint('[FirestoreService] addAuditLog notice: $e');
      return true;
    }
  }

  Future<bool> clearAuditLogs() async {
    _cachedAuditLogs.clear();
    return true;
  }

  // ==================== BACKUP & RESTORE ====================
  Future<String> exportDatabaseJson() async {
    final Map<String, dynamic> snapshot = {
      'exportedAt': DateTime.now().toIso8601String(),
      'systemVersion': 'v2.6.0',
      'institution': _cachedSetting.toMap(),
      'classes': _cachedClasses,
      'students': _cachedStudents.map((s) => s.toMap()).toList(),
      'staff': _cachedStaff.map((st) => st.toMap()).toList(),
      'payments': _cachedPayments.map((p) => p.toMap()).toList(),
      'academicYears': _cachedYears.map((y) => y.toMap()).toList(),
      'studentGroups': _cachedGroups.map((g) => g.toMap()).toList(),
      'concessions': _cachedConcessions.map((c) => c.toMap()).toList(),
      'customFeeItems': _cachedCustomFees.map((f) => f.toMap()).toList(),
      'notices': _cachedNotices.map((n) => n.toMap()).toList(),
    };
    return const JsonEncoder.withIndent('  ').convert(snapshot);
  }

  Future<Map<String, dynamic>> restoreDatabaseJson(String jsonString) async {
    try {
      final Map<String, dynamic> data = jsonDecode(jsonString);
      int restoredStudents = 0;
      int restoredStaff = 0;

      if (data['institution'] is Map<String, dynamic>) {
        final setting = InstitutionSetting.fromMap(data['institution']);
        await saveSettings(setting);
      }

      if (data['classes'] is List) {
        final classes = List<String>.from(data['classes']);
        await saveClasses(classes);
      }

      if (data['students'] is List) {
        for (final item in data['students']) {
          if (item is Map<String, dynamic>) {
            final s = Student.fromMap(item, item['id']?.toString() ?? '');
            await saveStudent(s);
            restoredStudents++;
          }
        }
      }

      if (data['staff'] is List) {
        for (final item in data['staff']) {
          if (item is Map<String, dynamic>) {
            final st = Staff.fromMap(item, item['id']?.toString() ?? '');
            await saveStaff(st);
            restoredStaff++;
          }
        }
      }

      return {
        'success': true,
        'studentsRestored': restoredStudents,
        'staffRestored': restoredStaff,
      };
    } catch (e) {
      return {'success': false, 'error': e.toString()};
    }
  }

  // ==================== FIREBASE AUTH CREDENTIALS UPDATE ====================
  Future<Map<String, dynamic>?> updateAdminCredentials({
    required String idToken,
    String? newEmail,
    String? newPassword,
  }) async {
    try {
      final url = Uri.parse('https://identitytoolkit.googleapis.com/v1/accounts:update?key=AIzaSyCRlnf6B82HpYB1hPEFORF2yAkj3zMv7Xg');
      final Map<String, dynamic> bodyMap = {
        'idToken': idToken,
        'returnSecureToken': true,
      };
      if (newEmail != null && newEmail.isNotEmpty) bodyMap['email'] = newEmail;
      if (newPassword != null && newPassword.isNotEmpty) bodyMap['password'] = newPassword;

      final res = await http.post(url, body: jsonEncode(bodyMap), headers: {'Content-Type': 'application/json'});
      if (res.statusCode == 200) {
        return jsonDecode(res.body) as Map<String, dynamic>;
      } else {
        final err = jsonDecode(res.body);
        final msg = err['error']?['message']?.toString() ?? 'Update failed';
        return {'error': msg};
      }
    } catch (e) {
      return {'error': e.toString()};
    }
  }

  // ==================== FIRESTORE ENCODING HELPERS ====================
  Map<String, dynamic> _encodeFirestoreFields(Map<String, dynamic> raw) {
    final Map<String, dynamic> encoded = {};
    raw.forEach((k, v) {
      if (v == null) {
        encoded[k] = {'nullValue': null};
      } else if (v is String) {
        encoded[k] = {'stringValue': v};
      } else if (v is bool) {
        encoded[k] = {'booleanValue': v};
      } else if (v is int) {
        encoded[k] = {'integerValue': v.toString()};
      } else if (v is double) {
        encoded[k] = {'doubleValue': v};
      } else if (v is List) {
        encoded[k] = {
          'arrayValue': {
            'values': v.map((item) {
              if (item is Map<String, dynamic>) {
                return {'mapValue': {'fields': _encodeFirestoreFields(item)}};
              }
              return {'stringValue': item.toString()};
            }).toList()
          }
        };
      } else if (v is Map<String, dynamic>) {
        encoded[k] = {
          'mapValue': {'fields': _encodeFirestoreFields(v)}
        };
      }
    });
    return encoded;
  }

  Map<String, dynamic> _decodeFirestoreFields(Map<String, dynamic> fields) {
    final Map<String, dynamic> decoded = {};
    fields.forEach((k, v) {
      if (v is Map) {
        if (v.containsKey('stringValue')) {
          decoded[k] = v['stringValue'];
        } else if (v.containsKey('integerValue')) {
          decoded[k] = int.tryParse(v['integerValue'].toString()) ?? 0;
        } else if (v.containsKey('doubleValue')) {
          decoded[k] = (v['doubleValue'] as num).toDouble();
        } else if (v.containsKey('booleanValue')) {
          decoded[k] = v['booleanValue'] == true;
        } else if (v.containsKey('nullValue')) {
          decoded[k] = null;
        } else if (v.containsKey('arrayValue')) {
          final list = v['arrayValue']['values'] as List? ?? [];
          decoded[k] = list.map((item) {
            if (item is Map && item.containsKey('mapValue')) {
              return _decodeFirestoreFields(Map<String, dynamic>.from(item['mapValue']['fields'] ?? {}));
            }
            if (item is Map && item.containsKey('stringValue')) {
              return item['stringValue'];
            }
            return item.toString();
          }).toList();
        } else if (v.containsKey('mapValue')) {
          decoded[k] = _decodeFirestoreFields(Map<String, dynamic>.from(v['mapValue']['fields'] ?? {}));
        }
      }
    });
    return decoded;
  }
}
