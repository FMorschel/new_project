// ignore_for_file: essential_lints/returning_widgets tests

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:new_project/widgets/template_validation_screen.dart';

Widget _wrap(Widget child) => MaterialApp(home: Scaffold(body: child));

void main() {
  group('TemplateValidationScreen', () {
    testWidgets('shows a loading/spinner state while validating', (
      tester,
    ) async {
      var completer = Completer<void>();
      await tester.pumpWidget(
        _wrap(
          TemplateValidationScreen(
            validationTask: completer.future,
            onSuccess: () {},
            onClose: () {},
          ),
        ),
      );

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('disappears automatically on success and navigates to wizard', (
      tester,
    ) async {
      var successCalled = false;
      await tester.pumpWidget(
        _wrap(
          TemplateValidationScreen(
            validationTask: Future<void>.value(),
            onSuccess: () {
              successCalled = true;
            },
            onClose: () {},
          ),
        ),
      );

      await tester.pump(); // Pump to let _validate finish.
      expect(successCalled, isTrue);
    });

    testWidgets(
      'persists with error details and a "Close" button on any validation failure',
      (tester) async {
        var closeCalled = false;
        var completer = Completer<void>();
        await tester.pumpWidget(
          _wrap(
            TemplateValidationScreen(
              validationTask: completer.future,
              onSuccess: () {},
              onClose: () {
                closeCalled = true;
              },
            ),
          ),
        );

        // Now complete it with error.
        completer.completeError(
          'Validation failed miserably.',
          StackTrace.current,
        );

        await tester.pump();
        await tester.pumpAndSettle();

        expect(find.byType(CircularProgressIndicator), findsNothing);
        expect(
          find.textContaining('Validation failed miserably.'),
          findsOneWidget,
        );
        var closeButton = find.widgetWithText(ElevatedButton, 'Close');
        expect(closeButton, findsOneWidget);

        await tester.tap(closeButton);
        expect(closeCalled, isTrue);
      },
    );
  });
}
