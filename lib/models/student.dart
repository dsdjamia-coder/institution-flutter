class Student {
  final String id;
  final String adm; // Immutable Primary Business Key
  final String name;
  final String studentClass;
  final int roll;
  final String gender;
  final String mobile;
  final String father;
  final String mother;
  final String dob;
  final String address;
  final String status; // 'Active', 'Inactive', 'Alumni', 'Discontinued'
  final String photo;
  final double concessionAmount;
  final String academicYear;
  final double frozenPendingDue;
  final String graduatedYear;
  final String completedClass;
  final String exitDate;
  final String exitReason;
  final String returnDate;
  final List<dynamic> continuityLog;

  Student({
    required this.id,
    required this.adm,
    required this.name,
    required this.studentClass,
    this.roll = 1,
    this.gender = 'Male',
    this.mobile = '',
    this.father = '',
    this.mother = '',
    this.dob = '',
    this.address = '',
    this.status = 'Active',
    this.photo = '',
    this.concessionAmount = 0.0,
    this.academicYear = '2026-2027',
    this.frozenPendingDue = 0.0,
    this.graduatedYear = '',
    this.completedClass = '',
    this.exitDate = '',
    this.exitReason = '',
    this.returnDate = '',
    this.continuityLog = const [],
  });

  /// Compound identity pill string to ensure zero ambiguity for identical names
  String get compoundIdentity {
    final fatherPart = father.isNotEmpty ? ' • S/o $father' : '';
    return '[#$adm] $name ($studentClass)$fatherPart';
  }

  factory Student.fromMap(Map<String, dynamic> map, String docId) {
    return Student(
      id: docId,
      adm: (map['adm'] ?? map['admissionNo'] ?? '').toString().trim(),
      name: (map['name'] ?? '').toString().trim(),
      studentClass: (map['class'] ?? map['studentClass'] ?? '').toString().trim(),
      roll: int.tryParse(map['roll']?.toString() ?? '') ?? 1,
      gender: (map['gender'] ?? 'Male').toString(),
      mobile: (map['mobile'] ?? map['phone'] ?? '').toString().trim(),
      father: (map['father'] ?? map['fatherName'] ?? map['guardianName'] ?? '').toString().trim(),
      mother: (map['mother'] ?? map['motherName'] ?? '').toString().trim(),
      dob: (map['dob'] ?? '').toString(),
      address: (map['address'] ?? '').toString(),
      status: (map['status'] ?? 'Active').toString(),
      photo: (map['photo'] ?? map['photoUrl'] ?? '').toString(),
      concessionAmount: double.tryParse(map['concessionAmount']?.toString() ?? '') ?? 0.0,
      academicYear: (map['academicYear'] ?? '2026-2027').toString(),
      frozenPendingDue: double.tryParse(map['frozenPendingDue']?.toString() ?? '') ?? 0.0,
      graduatedYear: (map['graduatedYear'] ?? '').toString(),
      completedClass: (map['completedClass'] ?? '').toString(),
      exitDate: (map['exitDate'] ?? '').toString(),
      exitReason: (map['exitReason'] ?? '').toString(),
      returnDate: (map['returnDate'] ?? '').toString(),
      continuityLog: map['continuityLog'] is List ? (map['continuityLog'] as List) : const [],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'adm': adm,
      'admissionNo': adm,
      'name': name.toUpperCase().trim(),
      'class': studentClass,
      'studentClass': studentClass,
      'roll': roll,
      'gender': gender,
      'mobile': mobile,
      'phone': mobile,
      'father': father.toUpperCase().trim(),
      'guardianName': father.toUpperCase().trim(),
      'mother': mother.toUpperCase().trim(),
      'dob': dob,
      'address': address,
      'status': status,
      'photo': photo,
      'photoUrl': photo,
      'concessionAmount': concessionAmount,
      'academicYear': academicYear,
      'frozenPendingDue': frozenPendingDue,
      'graduatedYear': graduatedYear,
      'completedClass': completedClass,
      'exitDate': exitDate,
      'exitReason': exitReason,
      'returnDate': returnDate,
      'continuityLog': continuityLog,
    };
  }

  Student copyWith({
    String? id,
    String? adm,
    String? name,
    String? studentClass,
    int? roll,
    String? gender,
    String? mobile,
    String? father,
    String? mother,
    String? dob,
    String? address,
    String? status,
    String? photo,
    double? concessionAmount,
    String? academicYear,
    double? frozenPendingDue,
    String? graduatedYear,
    String? completedClass,
    String? exitDate,
    String? exitReason,
    String? returnDate,
    List<dynamic>? continuityLog,
  }) {
    return Student(
      id: id ?? this.id,
      adm: adm ?? this.adm,
      name: name ?? this.name,
      studentClass: studentClass ?? this.studentClass,
      roll: roll ?? this.roll,
      gender: gender ?? this.gender,
      mobile: mobile ?? this.mobile,
      father: father ?? this.father,
      mother: mother ?? this.mother,
      dob: dob ?? this.dob,
      address: address ?? this.address,
      status: status ?? this.status,
      photo: photo ?? this.photo,
      concessionAmount: concessionAmount ?? this.concessionAmount,
      academicYear: academicYear ?? this.academicYear,
      frozenPendingDue: frozenPendingDue ?? this.frozenPendingDue,
      graduatedYear: graduatedYear ?? this.graduatedYear,
      completedClass: completedClass ?? this.completedClass,
      exitDate: exitDate ?? this.exitDate,
      exitReason: exitReason ?? this.exitReason,
      returnDate: returnDate ?? this.returnDate,
      continuityLog: continuityLog ?? this.continuityLog,
    );
  }
}
