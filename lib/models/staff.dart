class Staff {
  final String id;
  final String name;
  final String role; // 'ADMIN', 'TEACHER', 'COLLECTOR', 'OPERATOR'
  final String designation; // 'SWADAR', 'TEACHER', 'HEADMASTER', etc.
  final String phone;
  final String email;
  final String photoUrl;
  final String place;
  final String whatsapp;
  final String assignedClass;
  final List<String> assignedClasses;
  final String upiAccountName;
  final String upiId;
  final String samasthaRegNo;
  final bool hasCollectionAccess;
  final bool hasResultAccess;
  final bool hasWorksheetAccess;
  final bool hasAdminAccess;

  Staff({
    required this.id,
    required this.name,
    this.role = 'TEACHER',
    this.designation = 'TEACHER',
    this.phone = '',
    this.email = '',
    this.photoUrl = '',
    this.place = '',
    this.whatsapp = '',
    this.assignedClass = '',
    this.assignedClasses = const [],
    this.upiAccountName = '',
    this.upiId = '',
    this.samasthaRegNo = '',
    this.hasCollectionAccess = false,
    this.hasResultAccess = true,
    this.hasWorksheetAccess = true,
    this.hasAdminAccess = false,
  });

  factory Staff.fromMap(Map<String, dynamic> map, String docId) {
    return Staff(
      id: docId,
      name: map['name']?.toString() ?? '',
      role: map['role']?.toString() ?? 'TEACHER',
      designation: map['designation']?.toString() ?? (map['role']?.toString() ?? 'TEACHER'),
      phone: map['phone']?.toString() ?? '',
      email: map['email']?.toString() ?? '',
      photoUrl: map['photoUrl']?.toString() ?? '',
      place: map['place']?.toString() ?? '',
      whatsapp: map['whatsapp']?.toString() ?? (map['phone']?.toString() ?? ''),
      assignedClass: map['assignedClass']?.toString() ?? '',
      assignedClasses: map['assignedClasses'] != null
          ? List<String>.from(map['assignedClasses'])
          : (map['assignedClass'] != null && map['assignedClass'].toString().isNotEmpty
              ? [map['assignedClass'].toString()]
              : const []),
      upiAccountName: map['upiAccountName']?.toString() ?? '',
      upiId: map['upiId']?.toString() ?? '',
      samasthaRegNo: map['samasthaRegNo']?.toString() ?? '',
      hasCollectionAccess: map['hasCollectionAccess'] == true || map['collection'] == true,
      hasResultAccess: map['hasResultAccess'] == true || map['result'] == true,
      hasWorksheetAccess: map['hasWorksheetAccess'] == true || map['worksheet'] == true,
      hasAdminAccess: map['hasAdminAccess'] == true || map['admin'] == true || map['role'] == 'ADMIN',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'role': role,
      'designation': designation,
      'phone': phone,
      'email': email,
      'photoUrl': photoUrl,
      'place': place,
      'whatsapp': whatsapp,
      'assignedClass': assignedClass,
      'assignedClasses': assignedClasses,
      'upiAccountName': upiAccountName,
      'upiId': upiId,
      'samasthaRegNo': samasthaRegNo,
      'hasCollectionAccess': hasCollectionAccess,
      'hasResultAccess': hasResultAccess,
      'hasWorksheetAccess': hasWorksheetAccess,
      'hasAdminAccess': hasAdminAccess,
    };
  }

  Staff copyWith({
    String? id,
    String? name,
    String? role,
    String? designation,
    String? phone,
    String? email,
    String? photoUrl,
    String? place,
    String? whatsapp,
    String? assignedClass,
    List<String>? assignedClasses,
    String? upiAccountName,
    String? upiId,
    String? samasthaRegNo,
    bool? hasCollectionAccess,
    bool? hasResultAccess,
    bool? hasWorksheetAccess,
    bool? hasAdminAccess,
  }) {
    return Staff(
      id: id ?? this.id,
      name: name ?? this.name,
      role: role ?? this.role,
      designation: designation ?? this.designation,
      phone: phone ?? this.phone,
      email: email ?? this.email,
      photoUrl: photoUrl ?? this.photoUrl,
      place: place ?? this.place,
      whatsapp: whatsapp ?? this.whatsapp,
      assignedClass: assignedClass ?? this.assignedClass,
      assignedClasses: assignedClasses ?? this.assignedClasses,
      upiAccountName: upiAccountName ?? this.upiAccountName,
      upiId: upiId ?? this.upiId,
      samasthaRegNo: samasthaRegNo ?? this.samasthaRegNo,
      hasCollectionAccess: hasCollectionAccess ?? this.hasCollectionAccess,
      hasResultAccess: hasResultAccess ?? this.hasResultAccess,
      hasWorksheetAccess: hasWorksheetAccess ?? this.hasWorksheetAccess,
      hasAdminAccess: hasAdminAccess ?? this.hasAdminAccess,
    );
  }
}
