import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:dexor/app.dart';
import 'package:dexor/core/registry/tool_registry.dart';
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

  testWidgets('Implemented tool screens keep registry title consistency', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const DevToolsHubApp());
    final homeContext = tester.element(find.text('DevTools Hub'));

    final routesToVerify = ['/dev/base64', '/text/tokens'];
    for (final route in routesToVerify) {
      final entry = ToolRegistry.byRoute(route);
      if (entry == null) {
        fail('Expected "$route" to be present in ToolRegistry.');
      }
      Navigator.of(homeContext).pushNamed(route);
      await tester.pumpAndSettle();
      expect(find.text(entry.name), findsWidgets);
      Navigator.of(homeContext).pop();
      await tester.pumpAndSettle();
    }
  });
}
