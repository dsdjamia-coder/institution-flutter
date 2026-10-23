class StaffCategory {
  final String id;
  final String name;
  final int order;
  final bool showPublic;
  final bool isCore;

  StaffCategory({
    required this.id,
    required this.name,
    this.order = 1,
    this.showPublic = true,
    this.isCore = false,
  });

  factory StaffCategory.fromMap(Map<String, dynamic> map) {
    return StaffCategory(
      id: map['id']?.toString() ?? '',
      name: map['name']?.toString() ?? '',
      order: int.tryParse(map['order']?.toString() ?? '') ?? 1,
      showPublic: map['showPublic'] == true || map['public'] == true,
      isCore: map['isCore'] == true,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'order': order,
      'showPublic': showPublic,
      'isCore': isCore,
    };
  }

  StaffCategory copyWith({
    String? id,
    String? name,
    int? order,
    bool? showPublic,
    bool? isCore,
  }) {
    return StaffCategory(
      id: id ?? this.id,
      name: name ?? this.name,
      order: order ?? this.order,
      showPublic: showPublic ?? this.showPublic,
      isCore: isCore ?? this.isCore,
    );
  }
}
