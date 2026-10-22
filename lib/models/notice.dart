class Notice {
  final String id;
  final String heading;
  final String description;
  final String imageUrl;
  final String date;
  final bool isPinned;

  Notice({
    required this.id,
    this.heading = '',
    this.description = '',
    this.imageUrl = '',
    required this.date,
    this.isPinned = false,
  });

  factory Notice.fromMap(String id, Map<String, dynamic> map) {
    return Notice(
      id: id,
      heading: map['heading']?.toString() ?? '',
      description: map['description']?.toString() ?? map['text']?.toString() ?? '',
      imageUrl: map['imageUrl']?.toString() ?? map['imageData']?.toString() ?? '',
      date: map['date']?.toString() ?? DateTime.now().toString().split(' ')[0],
      isPinned: map['isPinned'] == true || map['pinned'] == true || map['isPinned']?.toString() == 'true',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'heading': heading,
      'description': description,
      'text': description,
      'imageUrl': imageUrl,
      'imageData': imageUrl,
      'date': date,
      'isPinned': isPinned,
      'pinned': isPinned,
    };
  }
}
