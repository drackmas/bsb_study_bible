import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import '../providers/commentary_provider.dart';
import '../services/scripture_parser.dart';

class CommentaryScreen extends StatelessWidget {
  const CommentaryScreen({
    super.key,
    this.isFullScreen = false,
  });

  final bool isFullScreen;

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<CommentaryProvider>();
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Commentary'),
        centerTitle: true,
        actions: [
          PopupMenuButton<String>(
            tooltip: 'Change source',
            onSelected: (name) {
              final source = provider.availableSources
                  .firstWhere((s) => s.name == name);
              provider.setSource(source);
            },
            itemBuilder: (_) => provider.availableSources
                .map((s) => PopupMenuItem(
                      value: s.name,
                      child: Row(
                        children: [
                          if (s.name == provider.activeSourceName)
                            Icon(Icons.check,
                                size: 18, color: colorScheme.primary),
                          if (s.name == provider.activeSourceName)
                            const SizedBox(width: 8),
                          Text(s.name),
                        ],
                      ),
                    ))
                .toList(),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    provider.activeSourceName,
                    style: TextStyle(
                      color: colorScheme.onSurfaceVariant,
                      fontSize: 14,
                    ),
                  ),
                  Icon(Icons.arrow_drop_down,
                      color: colorScheme.onSurfaceVariant),
                ],
              ),
            ),
          ),
        ],
      ),
      body: _buildBody(provider, colorScheme),
    );
  }

  Widget _buildBody(CommentaryProvider provider, ColorScheme colorScheme) {
    if (provider.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (provider.hasError) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.error_outline, size: 48, color: colorScheme.error),
              const SizedBox(height: 16),
              Text(
                provider.errorMessage ?? 'Something went wrong',
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              FilledButton(
                onPressed: () => provider.loadSource(),
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }

    final references = provider.availableReferences;

    if (references.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.auto_awesome_outlined,
                size: 64,
                color: colorScheme.onSurfaceVariant.withValues(alpha: 0.5),
              ),
              const SizedBox(height: 20),
              Text(
                'No commentary available',
                style: TextStyle(
                  fontSize: 16,
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      );
    }

    // List of commentaries in biblical order
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 40),
      itemCount: references.length,
      itemBuilder: (context, index) {
        final ref = references[index];
        final text = provider.getCommentaryText(ref) ?? '';

        return _CommentaryCard(
          reference: ref,
          commentary: text,
          onTapReference: () {
            // Jump to this verse in the Bible tab
            provider.requestBibleJump(ref);
          },
        );
      },
    );
  }
}

class _CommentaryCard extends StatelessWidget {
  final String reference;
  final String commentary;
  final VoidCallback onTapReference;

  const _CommentaryCard({
    required this.reference,
    required this.commentary,
    required this.onTapReference,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final parser = ScriptureParser();

    // Automatically turn plain references like (Isa. 7:14.) into clickable links
    final linkedCommentary = parser.linkifyReferences(commentary);

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 0,
      color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.6),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Tappable reference header
            InkWell(
              onTap: onTapReference,
              borderRadius: BorderRadius.circular(6),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Row(
                  children: [
                    Icon(
                      Icons.menu_book,
                      size: 18,
                      color: colorScheme.primary,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        reference,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: colorScheme.primary,
                        ),
                      ),
                    ),
                    Icon(
                      Icons.arrow_forward_ios,
                      size: 14,
                      color: colorScheme.primary.withValues(alpha: 0.7),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 10),

            // Commentary text with auto-linked references
            MarkdownBody(
              data: linkedCommentary,
              styleSheet: MarkdownStyleSheet(
                p: TextStyle(
                  fontSize: 15.5,
                  height: 1.55,
                  color: colorScheme.onSurface,
                ),
                strong: const TextStyle(fontWeight: FontWeight.w700),
                em: TextStyle(
                  fontStyle: FontStyle.italic,
                  color: colorScheme.onSurfaceVariant,
                ),
                a: TextStyle(
                  color: colorScheme.primary,
                  decoration: TextDecoration.underline,
                  fontWeight: FontWeight.w500,
                ),
              ),
              onTapLink: (text, href, title) {
                if (href == null) return;

                final ref = parser.parse(href);
                if (ref != null) {
                  context
                      .read<CommentaryProvider>()
                      .requestBibleJump(ref.toCanonical());
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}
