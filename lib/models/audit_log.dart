class AuditLogEntry {
  final String id;
  final String timestamp;
  final String category; // 'security', 'backup', 'student', 'class', 'group', 'fee', 'website'
  final String action;
  final String message;
  final String adminEmail;

  AuditLogEntry({
    required this.id,
    required this.timestamp,
    required this.category,
    required this.action,
    required this.message,
    required this.adminEmail,
  });

  factory AuditLogEntry.fromMap(String id, Map<String, dynamic> map) {
    return AuditLogEntry(
      id: id,
      timestamp: map['timestamp']?.toString() ?? DateTime.now().toIso8601String(),
      category: map['category']?.toString() ?? 'system',
      action: map['action']?.toString() ?? 'OPERATION',
      message: map['message']?.toString() ?? '',
      adminEmail: map['adminEmail']?.toString() ?? map['user']?.toString() ?? 'admin@system',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'timestamp': timestamp,
      'category': category,
      'action': action,
      'message': message,
      'adminEmail': adminEmail,
    };
  }
}
