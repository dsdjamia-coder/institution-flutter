class GalleryItem {
  final String id;
  final String imageUrl;
  final String title;
  final int displayOrder;

  GalleryItem({
    required this.id,
    required this.imageUrl,
    this.title = '',
    this.displayOrder = 50,
  });

  factory GalleryItem.fromMap(String id, Map<String, dynamic> map) {
    return GalleryItem(
      id: id,
      imageUrl: map['imageUrl']?.toString() ?? map['imageData']?.toString() ?? '',
      title: map['title']?.toString() ?? map['caption']?.toString() ?? '',
      displayOrder: int.tryParse(map['displayOrder']?.toString() ?? map['order']?.toString() ?? '') ?? 50,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'imageUrl': imageUrl,
      'imageData': imageUrl,
      'title': title,
      'caption': title,
      'displayOrder': displayOrder,
      'order': displayOrder,
    };
  }
}
