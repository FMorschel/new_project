// ignore_for_file: essential_lints/returning_widgets tests

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:new_project/models/template_parameter.dart';
import 'package:new_project/widgets/boolean_input_widget.dart';

TemplateParameter _makeParam() => const TemplateParameter(
  key: 'myKey',
  label: 'Enable Feature',
  type: ParameterType.boolean,
  required: true,
  passing: PassingConfig(style: PassingStyle.flag, flag: '--enable'),
);

Widget _wrap(Widget child) => MaterialApp(home: Scaffold(body: child));

void main() {
  group('BooleanInputWidget', () {
    testWidgets('renders parameter label', (tester) async {
      await tester.pumpWidget(
        _wrap(BooleanInputWidget(parameter: _makeParam(), onChanged: (_) {})),
      );

      expect(find.text('Enable Feature'), findsOneWidget);
    });

    testWidgets('calls onChanged(true) when toggled on', (tester) async {
      bool? captured;
      await tester.pumpWidget(
        _wrap(
          BooleanInputWidget(
            parameter: _makeParam(),
            onChanged: (v) => captured = v,
          ),
        ),
      );

      await tester.tap(find.byType(Checkbox));
      expect(captured, isTrue);
    });

    testWidgets('calls onChanged(false) when toggled off', (tester) async {
      bool? captured;
      await tester.pumpWidget(
        _wrap(
          BooleanInputWidget(
            parameter: _makeParam(),
            onChanged: (v) => captured = v,
            initialValue: true,
          ),
        ),
      );

      await tester.tap(find.byType(Checkbox));
      expect(captured, isFalse);
    });

    testWidgets('shows disabled state when isActive is false', (tester) async {
      await tester.pumpWidget(
        _wrap(
          BooleanInputWidget(
            parameter: _makeParam(),
            onChanged: (_) {},
            isActive: false,
            disabledExplanation: 'Requires Foo to be set.',
          ),
        ),
      );

      expect(
        tester.widget<CheckboxListTile>(find.byType(CheckboxListTile)).enabled,
        isFalse,
      );
    });

    testWidgets('shows explanation text when disabled', (tester) async {
      await tester.pumpWidget(
        _wrap(
          BooleanInputWidget(
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
