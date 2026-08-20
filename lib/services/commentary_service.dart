import 'dart:convert';
import 'package:flutter/services.dart';
import '../data/commentary_sources.dart';

class CommentaryService {
  final CommentarySource source;
  final Map<String, String> _cache = {};
  bool _loaded = false;

  CommentaryService({required this.source});

  Future<void> load() async {
    if (_loaded) return;

    try {
      final raw = await rootBundle.loadString(source.assetPath);
      final data = jsonDecode(raw) as Map<String, dynamic>;
      final commentary = data['commentary'] as Map<String, dynamic>? ?? data;

      _cache.clear();
      for (final entry in commentary.entries) {
        final value = entry.value;
        if (value != null && value.toString().isNotEmpty) {
          _cache[entry.key] = value.toString();
        }
      }

      _loaded = true;
    } catch (e) {
      rethrow;
    }
  }

  String? getCommentary(String canonicalRef) {
    return _cache[canonicalRef];
  }

  bool get isLoaded => _loaded;
  Map<String, String> get cache => Map.unmodifiable(_cache);
}
