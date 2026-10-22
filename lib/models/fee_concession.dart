class FeeConcession {
  final String studentId;
  final String studentName;
  final String studentClass;
  final double concessionMonthlyFee;
  final String reason;

  FeeConcession({
    required this.studentId,
    required this.studentName,
    required this.studentClass,
    required this.concessionMonthlyFee,
    this.reason = '',
  });

  factory FeeConcession.fromMap(String studentId, Map<String, dynamic> map) {
    return FeeConcession(
      studentId: studentId,
      studentName: map['studentName']?.toString() ?? '',
      studentClass: map['studentClass']?.toString() ?? '',
      concessionMonthlyFee: double.tryParse(map['concessionMonthlyFee']?.toString() ?? map['amount']?.toString() ?? map['fee']?.toString() ?? '') ?? 0.0,
      reason: map['reason']?.toString() ?? '',
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
      'reason': reason,
    };
  }

  FeeConcession copyWith({
    String? studentId,
    String? studentName,
    String? studentClass,
    double? concessionMonthlyFee,
    String? reason,
  }) {
    return FeeConcession(
      studentId: studentId ?? this.studentId,
      studentName: studentName ?? this.studentName,
      studentClass: studentClass ?? this.studentClass,
      concessionMonthlyFee: concessionMonthlyFee ?? this.concessionMonthlyFee,
      reason: reason ?? this.reason,
    );
  }
}
