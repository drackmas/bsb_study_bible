import 'chapter.dart';

class Book {
  final String name;
  final List<Chapter> chapters;

  const Book({
    required this.name,
    required this.chapters,
  });

  factory Book.fromJson(Map<String, dynamic> json) {
    final chaptersJson = json['chapters'] as List<dynamic>;
    return Book(
      name: json['name'] as String,
      chapters: chaptersJson
          .map((c) => Chapter.fromJson(c as Map<String, dynamic>))
          .toList(),
    );
  }
}
