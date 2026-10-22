class StudentGroup {
  final String id;
  final String name;
  final double monthlyFee;
  final List<String> memberStudentIds;

  StudentGroup({
    required this.id,
    required this.name,
    required this.monthlyFee,
    required this.memberStudentIds,
  });

  factory StudentGroup.fromMap(String id, Map<String, dynamic> map) {
    List<String> members = [];
    if (map['memberStudentIds'] is List) {
      members = (map['memberStudentIds'] as List).map((e) => e.toString()).toList();
    } else if (map['members'] is List) {
      members = (map['members'] as List).map((e) => e.toString()).toList();
    }

    return StudentGroup(
      id: id,
      name: map['name']?.toString() ?? 'Group',
      monthlyFee: double.tryParse(map['monthlyFee']?.toString() ?? map['fee']?.toString() ?? '') ?? 0.0,
      memberStudentIds: members,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'monthlyFee': monthlyFee,
      'fee': monthlyFee,
      'memberStudentIds': memberStudentIds,
      'members': memberStudentIds,
    };
  }
}
