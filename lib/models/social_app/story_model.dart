class StoryModel {
  final String id;
  final String userId;
  final String type; // 'image' or 'text'
  final String? imageUrl;
  final String? text;
  final DateTime createdAt;

  StoryModel({
    required this.id,
    required this.userId,
    required this.type,
    this.imageUrl,
    this.text,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'type': type,
      'imageUrl': imageUrl,
      'text': text,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory StoryModel.fromJson(Map<String, dynamic> json) {
    return StoryModel(
      id: json['id'],
      userId: json['userId'],
      type: json['type'],
      imageUrl: json['imageUrl'],
      text: json['text'],
      createdAt: DateTime.parse(json['createdAt']),
    );
  }
} 