import 'package:flutter_test/flutter_test.dart';
import 'package:saydaliati/app.dart';

void main() {
  testWidgets('App boots without crashing', (WidgetTester tester) async {
    await tester.pumpWidget(const SaydaliatiApp());
    await tester.pump(); // first frame
    // Allow async settings/favorites load without settling forever (map/network).
    await tester.pump(const Duration(milliseconds: 100));
    expect(find.byType(SaydaliatiApp), findsOneWidget);
  });
}
