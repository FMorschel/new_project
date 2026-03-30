// ignore_for_file: essential_lints/returning_widgets tests

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:new_project/models/template_parameter.dart';
import 'package:new_project/widgets/single_options_input_widget.dart';

TemplateParameter _makeParam() => const TemplateParameter(
  key: 'myKey',
  label: 'Pick One',
  type: ParameterType.options,
  options: ['Apple', 'Banana', 'Cherry'],
  required: true,
  passing: PassingConfig(style: PassingStyle.flagSpaceValue, flag: '--fruit'),
);

Widget _wrap(Widget child) => MaterialApp(home: Scaffold(body: child));

void main() {
  group('SingleOptionsInputWidget', () {
    testWidgets('renders all options when dropdown is opened', (tester) async {
      await tester.pumpWidget(
        _wrap(
          SingleOptionsInputWidget(parameter: _makeParam(), onChanged: (_) {}),
        ),
      );

      await tester.tap(find.byType(OutlinedButton));
      await tester.pumpAndSettle();

      expect(find.text('Apple'), findsOneWidget);
      expect(find.text('Banana'), findsOneWidget);
      expect(find.text('Cherry'), findsOneWidget);
    });

    testWidgets('typing in search field filters the option list', (
      tester,
    ) async {
      await tester.pumpWidget(
        _wrap(
          SingleOptionsInputWidget(parameter: _makeParam(), onChanged: (_) {}),
        ),
      );

      await tester.tap(find.byType(OutlinedButton));
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextField), 'an');
      await tester.pumpAndSettle();

      expect(find.text('Banana'), findsOneWidget);
      expect(find.text('Apple'), findsNothing);
      expect(find.text('Cherry'), findsNothing);
    });

    testWidgets('selecting an option calls onChanged with that value', (
      tester,
    ) async {
      String? captured;
      await tester.pumpWidget(
        _wrap(
          SingleOptionsInputWidget(
            parameter: _makeParam(),
            onChanged: (v) => captured = v,
          ),
        ),
      );

      await tester.tap(find.byType(OutlinedButton));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Banana'));
      expect(captured, 'Banana');
    });

    testWidgets('only one option can be selected at a time', (tester) async {
      String? captured;
      await tester.pumpWidget(
        _wrap(
          SingleOptionsInputWidget(
            parameter: _makeParam(),
            onChanged: (v) => captured = v,
          ),
        ),
      );

      await tester.tap(find.byType(OutlinedButton));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Apple'));
      await tester.pumpAndSettle();

      await tester.tap(find.byType(OutlinedButton));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Cherry'));
      await tester.pumpAndSettle();

      expect(captured, 'Cherry');
      expect(find.text('Apple'), findsNothing);
    });

    testWidgets('shows disabled state when isActive is false', (tester) async {
      await tester.pumpWidget(
        _wrap(
          SingleOptionsInputWidget(
            parameter: _makeParam(),
            onChanged: (_) {},
            isActive: false,
            disabledExplanation: 'Requires Foo to be set.',
          ),
        ),
      );

      expect(
        tester.widget<OutlinedButton>(find.byType(OutlinedButton)).onPressed,
        isNull,
      );
    });

    testWidgets('shows explanation text when disabled', (tester) async {
      await tester.pumpWidget(
        _wrap(
          SingleOptionsInputWidget(
            parameter: _makeParam(),
            onChanged: (_) {},
            isActive: false,
            disabledExplanation: 'Requires Foo to be set.',
          ),
        ),
      );

      expect(find.text('Requires Foo to be set.'), findsOneWidget);
    });
  });
}
