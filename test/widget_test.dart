import 'package:bible_app/main.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('Bible app renders', (WidgetTester tester) async {
    await tester.pumpWidget(const BibleApp());
    await tester.pump();
    expect(find.byType(BibleApp), findsOneWidget);
  });
}
