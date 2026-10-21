class FeeItemEntry {
  final String itemKey;
  final String itemLabel;
  final double amount;
  final String period; // e.g. "June-2026"
  final String ledgerKey; // studentId_year_itemKey_period

  FeeItemEntry({
    required this.itemKey,
    required this.itemLabel,
    required this.amount,
    required this.period,
    required this.ledgerKey,
  });

  factory FeeItemEntry.fromMap(Map<String, dynamic> map) {
    return FeeItemEntry(
      itemKey: map['itemKey']?.toString() ?? '',
      itemLabel: map['itemLabel']?.toString() ?? '',
      amount: double.tryParse(map['amount']?.toString() ?? '') ?? 0.0,
      period: map['period']?.toString() ?? '',
      ledgerKey: map['ledgerKey']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'itemKey': itemKey,
      'itemLabel': itemLabel,
      'amount': amount,
      'period': period,
      'ledgerKey': ledgerKey,
    };
  }
}

class Payment {
  final String id;
  final String paymentId;
  final int receiptNo;
  final String studentId;
  final String admissionNo;
  final String studentName;
  final String studentClass;
  final String academicYear;
  final double amount;
  final String paymentDate;
  final String paymentMode; // CASH, UPI, BANK
  final List<FeeItemEntry> feeItems;
  final String collectedByName;
  final String status; // VALID, VOIDED
  final int timestamp;

  Payment({
    required this.id,
    required this.paymentId,
    required this.receiptNo,
    required this.studentId,
    required this.admissionNo,
    required this.studentName,
    required this.studentClass,
    required this.academicYear,
    required this.amount,
    required this.paymentDate,
    this.paymentMode = 'CASH',
    required this.feeItems,
    this.collectedByName = 'Admin Desk',
    this.status = 'VALID',
    int? timestamp,
  }) : timestamp = timestamp ?? DateTime.now().millisecondsSinceEpoch;

  factory Payment.fromMap(Map<String, dynamic> map, String docId) {
    var rawItems = map['feeItems'];
    List<FeeItemEntry> items = [];
    if (rawItems is List) {
      items = rawItems.map((i) => FeeItemEntry.fromMap(Map<String, dynamic>.from(i))).toList();
    }

    return Payment(
      id: docId,
      paymentId: map['paymentId']?.toString() ?? docId,
      receiptNo: int.tryParse(map['receiptNo']?.toString() ?? '') ?? 1001,
      studentId: map['studentId']?.toString() ?? '',
      admissionNo: (map['admissionNo'] ?? map['studentAdm'] ?? '').toString(),
      studentName: map['studentName']?.toString() ?? '',
      studentClass: (map['class'] ?? map['studentClass'] ?? '').toString(),
      academicYear: map['academicYear']?.toString() ?? '2026-2027',
      amount: double.tryParse(map['amount']?.toString() ?? '') ?? 0.0,
      paymentDate: map['paymentDate']?.toString() ?? DateTime.now().toString().split(' ')[0],
      paymentMode: map['paymentMode']?.toString() ?? 'CASH',
      feeItems: items,
      collectedByName: map['collectedByName']?.toString() ?? 'Admin Desk',
      status: map['status']?.toString() ?? 'VALID',
      timestamp: int.tryParse(map['timestamp']?.toString() ?? '') ?? DateTime.now().millisecondsSinceEpoch,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'paymentId': paymentId,
      'receiptNo': receiptNo,
      'studentId': studentId,
      'admissionNo': admissionNo,
      'studentName': studentName,
      'class': studentClass,
      'studentClass': studentClass,
      'academicYear': academicYear,
      'amount': amount,
      'paymentDate': paymentDate,
      'paymentMode': paymentMode,
      'feeItems': feeItems.map((i) => i.toMap()).toList(),
      'collectedByName': collectedByName,
      'status': status,
      'timestamp': timestamp,
    };
  }
}
