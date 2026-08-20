class BibleJumpRequest {
  final String bookName;
  final int chapter;
  final int verse;

  const BibleJumpRequest({
    required this.bookName,
    required this.chapter,
    required this.verse,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is BibleJumpRequest &&
          runtimeType == other.runtimeType &&
          bookName == other.bookName &&
          chapter == other.chapter &&
          verse == other.verse;

  @override
  int get hashCode => Object.hash(bookName, chapter, verse);
}
