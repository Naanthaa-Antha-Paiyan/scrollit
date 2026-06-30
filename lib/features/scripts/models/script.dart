class Script {
  final String id;
  final String title;
  final String content;
  final int wordCount;
  final DateTime createdAt;
  final DateTime updatedAt;
  final double lastPosition;

  const Script({
    required this.id,
    required this.title,
    required this.content,
    required this.createdAt,
    required this.updatedAt,
    this.wordCount = 0,
    this.lastPosition = 0.0,
  });

  Script copyWith({
    String? id,
    String? title,
    String? content,
    int? wordCount,
    DateTime? createdAt,
    DateTime? updatedAt,
    double? lastPosition,
  }) {
    return Script(
      id: id ?? this.id,
      title: title ?? this.title,
      content: content ?? this.content,
      wordCount: wordCount ?? this.wordCount,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      lastPosition: lastPosition ?? this.lastPosition,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'wordCount': wordCount,
        'createdAt': createdAt.toIso8601String(),
        'updatedAt': updatedAt.toIso8601String(),
      };

  factory Script.fromJson(Map<String, dynamic> json) => Script(
        id: json['id'] as String,
        title: json['title'] as String,
        content: '',
        wordCount: (json['wordCount'] as num?)?.toInt() ?? 0,
        createdAt: DateTime.parse(json['createdAt'] as String),
        updatedAt: DateTime.parse(json['updatedAt'] as String),
      );

  static int countWords(String text) {
    if (text.trim().isEmpty) return 0;
    return text.trim().split(RegExp(r'\s+')).length;
  }
}
