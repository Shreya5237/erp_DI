import 'package:flutter_test/flutter_test.dart';
import 'package:digital_inertia_erp/main.dart';

void main() {
  testWidgets('ERP App smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const DigitalInertiaErpApp());

    // Verify that the title appears
    expect(find.text('DIGITAL INERTIA'), findsOneWidget);
  });
}
