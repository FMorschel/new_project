// ignore_for_file: essential_lints/returning_widgets tests

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:new_project/widgets/loading_screen.dart';

Widget _wrap(Widget child) => MaterialApp(home: child);

void main() {
  group('LoadingScreen', () {
    testWidgets('shows full-screen spinner with "Creating project…" label', (
      tester,
    ) async {
      await tester.pumpWidget(_wrap(const LoadingScreen()));

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(find.text('Creating project…'), findsOneWidget);
    });

    testWidgets('no cancel button is present', (tester) async {
      await tester.pumpWidget(_wrap(const LoadingScreen()));

      expect(find.byType(TextButton), findsNothing);
      expect(find.byType(ElevatedButton), findsNothing);
      expect(find.byType(OutlinedButton), findsNothing);
      expect(find.byType(IconButton), findsNothing);
      expect(
        find.textContaining(RegExp('cancel', caseSensitive: false)),
        findsNothing,
      );
    });
  });
}
