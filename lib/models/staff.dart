class Staff {
  final String id;
  final String name;
  final String role; // 'ADMIN', 'TEACHER', 'COLLECTOR', 'OPERATOR'
  final String phone;
  final String email;
  final String assignedClass;
  final bool hasCollectionAccess;
  final bool hasResultAccess;
  final bool hasWorksheetAccess;
  final bool hasAdminAccess;

  Staff({
    required this.id,
    required this.name,
    this.role = 'TEACHER',
    this.phone = '',
    this.email = '',
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
      phone: map['phone']?.toString() ?? '',
      email: map['email']?.toString() ?? '',
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
      'phone': phone,
      'email': email,
      'assignedClass': assignedClass,
      'hasCollectionAccess': hasCollectionAccess,
      'hasResultAccess': hasResultAccess,
      'hasWorksheetAccess': hasWorksheetAccess,
      'hasAdminAccess': hasAdminAccess,
    };
  }
}
