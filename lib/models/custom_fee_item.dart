class CustomFeeItem {
  final String id;
  final String name;
  final String scope; // 'global', 'class-wise', 'specific'
  final double globalAmount;
  final Map<String, double> classWiseAmounts;
  final String specificClass;
  final bool isReceiptRequired;

  CustomFeeItem({
    required this.id,
    required this.name,
    this.scope = 'global',
    this.globalAmount = 0.0,
    this.classWiseAmounts = const {},
    this.specificClass = '',
    this.isReceiptRequired = false,
  });

  factory CustomFeeItem.fromMap(String id, Map<String, dynamic> map) {
    Map<String, double> cw = {};
    if (map['classWiseAmounts'] is Map) {
      (map['classWiseAmounts'] as Map).forEach((k, v) {
        cw[k.toString()] = double.tryParse(v.toString()) ?? 0.0;
      });
    }

    return CustomFeeItem(
      id: id,
      name: map['name']?.toString() ?? '',
      scope: map['scope']?.toString() ?? 'global',
      globalAmount: double.tryParse(map['globalAmount']?.toString() ?? map['amount']?.toString() ?? '') ?? 0.0,
      classWiseAmounts: cw,
      specificClass: map['specificClass']?.toString() ?? '',
      isReceiptRequired: map['isReceiptRequired'] == true || map['isReceiptRequired']?.toString() == 'true',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'scope': scope,
      'globalAmount': globalAmount,
      'amount': globalAmount,
      'classWiseAmounts': classWiseAmounts,
      'specificClass': specificClass,
      'isReceiptRequired': isReceiptRequired,
    };
  }

  CustomFeeItem copyWith({
    String? id,
    String? name,
    String? scope,
    double? globalAmount,
    Map<String, double>? classWiseAmounts,
    String? specificClass,
    bool? isReceiptRequired,
  }) {
    return CustomFeeItem(
      id: id ?? this.id,
      name: name ?? this.name,
      scope: scope ?? this.scope,
      globalAmount: globalAmount ?? this.globalAmount,
      classWiseAmounts: classWiseAmounts ?? this.classWiseAmounts,
      specificClass: specificClass ?? this.specificClass,
      isReceiptRequired: isReceiptRequired ?? this.isReceiptRequired,
    );
  }
}
