// ignore_for_file: essential_lints/returning_widgets tests

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:new_project/models/template_parameter.dart';
import 'package:new_project/widgets/integer_input_widget.dart';

TemplateParameter _makeParam() => const TemplateParameter(
  key: 'myKey',
  label: 'My Integer',
  type: ParameterType.integer,
  required: true,
  passing: PassingConfig(style: PassingStyle.flagSpaceValue, flag: '--count'),
);

Widget _wrap(Widget child) => MaterialApp(home: Scaffold(body: child));

void main() {
  group('IntegerInputWidget', () {
    testWidgets('accepts digit characters', (tester) async {
      String? captured;
      await tester.pumpWidget(
        _wrap(
          IntegerInputWidget(
            parameter: _makeParam(),
            onChanged: (v) => captured = v,
          ),
        ),
      );

      await tester.enterText(find.byType(TextField), '42');
      expect(captured, '42');
    });

    testWidgets('rejects letter characters', (tester) async {
      await tester.pumpWidget(
        _wrap(IntegerInputWidget(parameter: _makeParam(), onChanged: (_) {})),
      );

      await tester.enterText(find.byType(TextField), 'abc');
      expect(
        tester.widget<TextField>(find.byType(TextField)).controller!.text,
        isEmpty,
      );
    });

    testWidgets('rejects dot character', (tester) async {
      String? captured;
      await tester.pumpWidget(
        _wrap(
          IntegerInputWidget(
            parameter: _makeParam(),
            onChanged: (v) => captured = v,
          ),
        ),
      );

      await tester.enterText(find.byType(TextField), '3.14');
      expect(
        tester.widget<TextField>(find.byType(TextField)).controller!.text,
        '314',
      );
      expect(captured, '314');
    });

    testWidgets('calls onChanged with integer string', (tester) async {
      String? captured;
      await tester.pumpWidget(
        _wrap(
          IntegerInputWidget(
            parameter: _makeParam(),
            onChanged: (v) => captured = v,
          ),
        ),
      );

      await tester.enterText(find.byType(TextField), '123');
      expect(captured, '123');
    });

    testWidgets('shows disabled state when isActive is false', (tester) async {
      await tester.pumpWidget(
        _wrap(
          IntegerInputWidget(
            parameter: _makeParam(),
            onChanged: (_) {},
            isActive: false,
            disabledExplanation: 'Requires Foo to be set.',
          ),
        ),
      );

      expect(tester.widget<TextField>(find.byType(TextField)).enabled, isFalse);
    });

    testWidgets('shows explanation text when disabled', (tester) async {
      await tester.pumpWidget(
        _wrap(
          IntegerInputWidget(
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
