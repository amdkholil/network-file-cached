import 'package:example/main.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('App renders test', (WidgetTester tester) async {
    await tester.pumpWidget(const MyApp());
    expect(find.text('Network File Cached Example'), findsOneWidget);
  });
}
