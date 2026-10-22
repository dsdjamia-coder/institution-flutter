class AcademicYearConfig {
  final String label;
  final String startMonth;
  final String endMonth;
  final String status; // 'active', 'current', 'archived'

  AcademicYearConfig({
    required this.label,
    this.startMonth = 'June',
    this.endMonth = 'March',
    this.status = 'active',
  });

  factory AcademicYearConfig.fromMap(Map<String, dynamic> map) {
    return AcademicYearConfig(
      label: map['label']?.toString() ?? map['year']?.toString() ?? '2026-2027',
      startMonth: map['startMonth']?.toString() ?? 'June',
      endMonth: map['endMonth']?.toString() ?? 'March',
      status: map['status']?.toString() ?? 'active',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'label': label,
      'year': label,
      'startMonth': startMonth,
      'endMonth': endMonth,
      'status': status,
    };
  }
}
