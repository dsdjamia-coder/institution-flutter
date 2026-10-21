class ExamResult {
  final String id;
  final String examId;
  final String studentId;
  final String admissionNo;
  final String studentName;
  final String studentClass;
  final String academicYear;
  final Map<String, double> marks;
  final double total;
  final double percentage;
  final String grade;
  final bool published;

  ExamResult({
    required this.id,
    required this.examId,
    required this.studentId,
    required this.admissionNo,
    required this.studentName,
    required this.studentClass,
    required this.academicYear,
    required this.marks,
    required this.total,
    required this.percentage,
    required this.grade,
    this.published = false,
  });

  static String calculateGrade(double pct) {
    if (pct >= 90) return 'A+';
    if (pct >= 80) return 'A';
    if (pct >= 70) return 'B+';
    if (pct >= 60) return 'B';
    if (pct >= 50) return 'C+';
    if (pct >= 40) return 'C';
    if (pct >= 35) return 'D';
    return 'F';
  }

  factory ExamResult.fromMap(Map<String, dynamic> map, String docId) {
    Map<String, double> parsedMarks = {};
    if (map['marks'] is Map) {
      (map['marks'] as Map).forEach((k, v) {
        parsedMarks[k.toString()] = double.tryParse(v.toString()) ?? 0.0;
      });
    }

    return ExamResult(
      id: docId,
      examId: map['examId']?.toString() ?? '',
      studentId: map['studentId']?.toString() ?? '',
      admissionNo: (map['admissionNo'] ?? map['adm'] ?? '').toString(),
      studentName: (map['studentName'] ?? map['name'] ?? '').toString(),
      studentClass: (map['class'] ?? map['studentClass'] ?? '').toString(),
      academicYear: map['academicYear']?.toString() ?? '2026-2027',
      marks: parsedMarks,
      total: double.tryParse(map['total']?.toString() ?? '') ?? 0.0,
      percentage: double.tryParse(map['percentage']?.toString() ?? '') ?? 0.0,
      grade: map['grade']?.toString() ?? 'F',
      published: map['published'] == true,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'examId': examId,
      'studentId': studentId,
      'admissionNo': admissionNo,
      'adm': admissionNo,
      'studentName': studentName,
      'name': studentName,
      'class': studentClass,
      'studentClass': studentClass,
      'academicYear': academicYear,
      'marks': marks,
      'total': total,
      'percentage': percentage,
      'grade': grade,
      'published': published,
      'updatedAt': DateTime.now().millisecondsSinceEpoch,
    };
  }
}
