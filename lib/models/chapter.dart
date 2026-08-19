import 'verse.dart';

class Chapter {
  final int chapter;
  final String name;
  final List<Verse> verses;

  const Chapter({
    required this.chapter,
    required this.name,
    required this.verses,
  });

  factory Chapter.fromJson(Map<String, dynamic> json) {
    final versesJson = json['verses'] as List<dynamic>;
    return Chapter(
      chapter: json['chapter'] as int,
      name: json['name'] as String,
      verses: versesJson
          .map((v) => Verse.fromJson(v as Map<String, dynamic>))
          .toList(),
    );
  }
}
