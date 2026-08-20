class CommentarySource {
  final String id;
  final String name;
  final String assetPath;

  const CommentarySource({
    required this.id,
    required this.name,
    required this.assetPath,
  });
}

const abbottSource = CommentarySource(
  id: 'abbott_bsb',
  name: 'Abbott',
  assetPath: 'assets/commentary/abbott_bsb.json',
);

const commentarySources = [
  abbottSource,
];
