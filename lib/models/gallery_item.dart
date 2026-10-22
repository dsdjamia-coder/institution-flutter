class GalleryItem {
  final String id;
  final String imageUrl;
  final int displayOrder;

  GalleryItem({
    required this.id,
    required this.imageUrl,
    this.displayOrder = 50,
  });

  factory GalleryItem.fromMap(String id, Map<String, dynamic> map) {
    return GalleryItem(
      id: id,
      imageUrl: map['imageUrl']?.toString() ?? map['imageData']?.toString() ?? '',
      displayOrder: int.tryParse(map['displayOrder']?.toString() ?? map['order']?.toString() ?? '') ?? 50,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'imageUrl': imageUrl,
      'imageData': imageUrl,
      'displayOrder': displayOrder,
      'order': displayOrder,
    };
  }
}
