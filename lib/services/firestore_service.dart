import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../config/app_constants.dart';
import '../models/institution_setting.dart';
import '../models/student.dart';
import '../models/payment.dart';
import '../models/staff.dart';
import '../models/exam_result.dart';

/// Firebase Firestore Communication Service
class FirestoreService {
  final String baseUrl = AppConstants.firestoreBaseUrl;

  // Local state cache
  InstitutionSetting _cachedSetting = InstitutionSetting();
  List<String> _cachedClasses = [];
  final List<Student> _cachedStudents = [];
  final List<Payment> _cachedPayments = [];
  final List<Staff> _cachedStaff = [];
  final List<ExamResult> _cachedResults = [];

  // ==================== SETTINGS ====================
  Future<InstitutionSetting> fetchSettings() async {
    try {
      final url = Uri.parse('$baseUrl/settings/general');
      final res = await http.get(url);
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
      final url = Uri.parse('$baseUrl/settings/general');
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
    final docId = 'STF_${DateTime.now().millisecondsSinceEpoch}';
    final newStaff = Staff(
      id: docId,
      name: staff.name,
      role: staff.role,
      phone: staff.phone,
      email: staff.email,
      assignedClass: staff.assignedClass,
      hasCollectionAccess: staff.hasCollectionAccess,
      hasResultAccess: staff.hasResultAccess,
      hasWorksheetAccess: staff.hasWorksheetAccess,
      hasAdminAccess: staff.hasAdminAccess,
    );
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
