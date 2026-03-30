// ignore_for_file: essential_lints/returning_widgets tests

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:new_project/models/template_parameter.dart';
import 'package:new_project/widgets/num_input_widget.dart';

TemplateParameter _makeParam() => const TemplateParameter(
  key: 'myKey',
  label: 'My Number',
  type: ParameterType.num,
  required: true,
  passing: PassingConfig(style: PassingStyle.flagSpaceValue, flag: '--value'),
);

Widget _wrap(Widget child) => MaterialApp(home: Scaffold(body: child));

void main() {
  group('NumInputWidget', () {
    testWidgets('accepts digits and dot', (tester) async {
      String? captured;
      await tester.pumpWidget(
        _wrap(
          NumInputWidget(
            parameter: _makeParam(),
            onChanged: (v) => captured = v,
          ),
        ),
      );

      await tester.enterText(find.byType(TextField), '3.14');
      expect(captured, '3.14');
    });

    testWidgets('rejects letter characters', (tester) async {
      await tester.pumpWidget(
        _wrap(NumInputWidget(parameter: _makeParam(), onChanged: (_) {})),
      );

      await tester.enterText(find.byType(TextField), 'abc');
      expect(
        tester.widget<TextField>(find.byType(TextField)).controller!.text,
        isEmpty,
      );
    });

    testWidgets('rejects multiple dot characters', (tester) async {
      String? captured;
      await tester.pumpWidget(
        _wrap(
          NumInputWidget(
            parameter: _makeParam(),
            onChanged: (v) => captured = v,
          ),
        ),
      );

      await tester.enterText(find.byType(TextField), '1.2.3');
      expect(
        tester.widget<TextField>(find.byType(TextField)).controller!.text,
        '1.23',
      );
      expect(captured, '1.23');
    });

    testWidgets('calls onChanged with numeric string', (tester) async {
      String? captured;
      await tester.pumpWidget(
        _wrap(
          NumInputWidget(
            parameter: _makeParam(),
            onChanged: (v) => captured = v,
          ),
        ),
      );

      await tester.enterText(find.byType(TextField), '2.718');
      expect(captured, '2.718');
    });

    testWidgets('shows disabled state when isActive is false', (tester) async {
      await tester.pumpWidget(
        _wrap(
          NumInputWidget(
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
          NumInputWidget(
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
