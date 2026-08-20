import 'package:bible_app/main.dart';
import 'package:bible_app/providers/theme_provider.dart';
import 'package:bible_app/providers/commentary_provider.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

void main() {
  testWidgets('Bible app renders', (WidgetTester tester) async {
    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => ThemeProvider()),
          ChangeNotifierProvider(create: (_) => CommentaryProvider()),
        ],
        child: const BibleApp(),
      ),
    );
    await tester.pump();
    expect(find.byType(BibleApp), findsOneWidget);
  });
}
