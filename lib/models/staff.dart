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
      'hasCollectionAccess': hasCollectionAccess,
      'hasResultAccess': hasResultAccess,
      'hasWorksheetAccess': hasWorksheetAccess,
      'hasAdminAccess': hasAdminAccess,
    };
  }
}
