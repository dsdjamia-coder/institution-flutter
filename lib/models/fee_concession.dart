class FeeConcession {
  final String studentId;
  final String studentName;
  final String studentClass;
  final double concessionMonthlyFee;

  FeeConcession({
    required this.studentId,
    required this.studentName,
    required this.studentClass,
    required this.concessionMonthlyFee,
  });

  factory FeeConcession.fromMap(String studentId, Map<String, dynamic> map) {
    return FeeConcession(
      studentId: studentId,
      studentName: map['studentName']?.toString() ?? '',
      studentClass: map['studentClass']?.toString() ?? '',
      concessionMonthlyFee: double.tryParse(map['concessionMonthlyFee']?.toString() ?? map['amount']?.toString() ?? map['fee']?.toString() ?? '') ?? 0.0,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'studentId': studentId,
      'studentName': studentName,
      'studentClass': studentClass,
      'concessionMonthlyFee': concessionMonthlyFee,
      'amount': concessionMonthlyFee,
      'fee': concessionMonthlyFee,
    };
  }
}
