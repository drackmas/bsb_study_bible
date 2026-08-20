import 'package:flutter/material.dart';
import '../models/chapter.dart';

class ChapterPicker extends StatelessWidget {
  final List<Chapter> chapters;
  final int currentChapter;
  final void Function(Chapter) onSelect;

  const ChapterPicker({
    super.key,
    required this.chapters,
    required this.currentChapter,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Select Chapter'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: GridView.builder(
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 6,
            crossAxisSpacing: 8,
            mainAxisSpacing: 8,
          ),
          itemCount: chapters.length,
          itemBuilder: (context, index) {
            final chapter = chapters[index];
            final isSelected = chapter.chapter == currentChapter;
            return Material(
              color: isSelected
                  ? Theme.of(context).colorScheme.primaryContainer
                  : Theme.of(context).colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(8),
              child: InkWell(
                borderRadius: BorderRadius.circular(8),
                onTap: () => onSelect(chapter),
                child: Center(
                  child: Text(
                    '${chapter.chapter}',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                      color: isSelected
                          ? Theme.of(context).colorScheme.onPrimaryContainer
                          : Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
