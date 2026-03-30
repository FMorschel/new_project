// ignore_for_file: essential_lints/returning_widgets tests

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:new_project/widgets/result_screen.dart';

Widget _wrap(Widget child) => MaterialApp(home: child);

void main() {
  group('ResultScreen', () {
    testWidgets('shows success message on exit code 0', (tester) async {
      await tester.pumpWidget(
        _wrap(
          ResultScreen(
            exitCode: 0,
            stdout: 'done',
            stderr: '',
            onClose: () {},
            onRetry: () {},
          ),
        ),
      );

      expect(find.text('Project created successfully!'), findsOneWidget);
      expect(find.byIcon(Icons.check_circle_outline), findsOneWidget);
    });

    testWidgets('shows error message and non-zero exit code on failure', (
      tester,
    ) async {
      await tester.pumpWidget(
        _wrap(
          ResultScreen(
            exitCode: 123,
            stdout: '',
            stderr: 'file not found',
            onClose: () {},
            onRetry: () {},
          ),
        ),
      );

      expect(find.text('Project creation failed.'), findsOneWidget);
      expect(find.text('Exit code: 123'), findsOneWidget);
      expect(find.byIcon(Icons.error_outline), findsOneWidget);
    });

    testWidgets(
      'stdout/stderr foldable section is collapsed on success by default',
      (tester) async {
        await tester.pumpWidget(
          _wrap(
            ResultScreen(
              exitCode: 0,
              stdout: 'all good',
              stderr: '',
              onClose: () {},
              onRetry: () {},
            ),
          ),
        );

        // ExpansionTile collapsed means we shouldn't see the text immediately.
        expect(find.textContaining('all good'), findsNothing);
      },
    );

    testWidgets(
      'stdout/stderr foldable section is expanded on error by default',
      (tester) async {
        await tester.pumpWidget(
          _wrap(
            ResultScreen(
              exitCode: 1,
              stdout: '',
              stderr: 'boom',
              onClose: () {},
              onRetry: () {},
            ),
          ),
        );

        expect(find.textContaining('boom'), findsOneWidget);
      },
    );

    testWidgets('"Close" button exposes onClose callback', (tester) async {
      var called = false;
      await tester.pumpWidget(
        _wrap(
          ResultScreen(
            exitCode: 0,
            stdout: '',
            stderr: '',
            onClose: () => called = true,
            onRetry: () {},
          ),
        ),
      );

      await tester.tap(find.widgetWithText(ElevatedButton, 'Close'));
      expect(called, isTrue);
    });

    testWidgets('"Edit and retry" exposes onRetry callback', (tester) async {
      var called = false;
      await tester.pumpWidget(
        _wrap(
          ResultScreen(
            exitCode: 1,
            stdout: '',
            stderr: '',
            onClose: () {},
            onRetry: () => called = true,
          ),
        ),
      );

      await tester.tap(find.widgetWithText(OutlinedButton, 'Edit and retry'));
      expect(called, isTrue);
    });
  });
}
