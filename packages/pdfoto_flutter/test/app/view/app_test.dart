import 'package:flutter_test/flutter_test.dart';
import 'package:pdfoto_flutter/app/app.dart';
import 'package:pdfoto_flutter/pdf_builder/pdf_builder.dart';

void main() {
  group('App', () {
    testWidgets('renders CounterPage', (tester) async {
      await tester.pumpWidget(const App());
      expect(find.byType(PdfBuilderPage), findsOneWidget);
    });
  });
}
