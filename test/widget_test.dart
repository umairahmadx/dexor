import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:dexor/app.dart';
import 'package:dexor/features/pdf_tools/pdf_toolkit_models.dart';
import 'package:dexor/features/pdf_tools/pdf_toolkit_screen.dart';

void main() {
  testWidgets('App smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const DevToolsHubApp());

    // Verify that the app title is shown.
    expect(find.text('DevTools Hub'), findsOneWidget);
  });

  testWidgets('PDF toolkit opens requested section', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(home: PdfToolkitScreen(initialTool: PdfToolId.redact)),
    );

    expect(find.text('PDF Toolkit'), findsOneWidget);
    expect(find.text('Security'), findsOneWidget);
    expect(find.text('Redact PDF'), findsAtLeastNWidgets(1));
    expect(find.text('Redaction mode'), findsOneWidget);
  });
}
