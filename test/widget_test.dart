import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:digital_inertia_erp/main.dart';
import 'package:digital_inertia_erp/providers/erp_provider.dart';

void main() {
  testWidgets('ERP App smoke test', (WidgetTester tester) async {
    // Build our app with ErpProvider and trigger a frame.
    await tester.pumpWidget(
      ChangeNotifierProvider(
        create: (_) => ErpProvider(),
        child: const DigitalInertiaErpApp(),
      ),
    );
    await tester.pumpAndSettle();

    // Verify that the app mounts and Instrument Sans font is loaded
    expect(find.byType(DigitalInertiaErpApp), findsOneWidget);
    expect(GoogleFonts.instrumentSans().fontFamily, contains('InstrumentSans'));
  });
}
