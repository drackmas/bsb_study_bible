class Verse {
  final int verse;
  final int chapter;
  final String name;
  final String text;

  const Verse({
    required this.verse,
    required this.chapter,
    required this.name,
    required this.text,
  });

  factory Verse.fromJson(Map<String, dynamic> json) {
    return Verse(
      verse: json['verse'] as int,
      chapter: json['chapter'] as int,
      name: json['name'] as String,
      text: json['text'] as String,
    );
  }
}
