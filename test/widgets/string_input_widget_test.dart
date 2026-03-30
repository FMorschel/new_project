// ignore_for_file: essential_lints/returning_widgets tests

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:new_project/models/template_parameter.dart';
import 'package:new_project/widgets/string_input_widget.dart';

TemplateParameter _makeParam({String? description}) => TemplateParameter(
  key: 'myKey',
  label: 'My Label',
  description: description,
  type: ParameterType.string,
  required: true,
  passing: const PassingConfig(
    style: PassingStyle.flagSpaceValue,
    flag: '--name',
  ),
);

Widget _wrap(Widget child) => MaterialApp(home: Scaffold(body: child));

void main() {
  group('StringInputWidget', () {
    testWidgets('renders label', (tester) async {
      await tester.pumpWidget(
        _wrap(StringInputWidget(parameter: _makeParam(), onChanged: (_) {})),
      );

      expect(find.text('My Label'), findsOneWidget);
    });

    testWidgets('renders description when present', (tester) async {
      await tester.pumpWidget(
        _wrap(
          StringInputWidget(
            parameter: _makeParam(description: 'Some description'),
            onChanged: (_) {},
          ),
        ),
      );

      expect(find.text('Some description'), findsOneWidget);
    });

    testWidgets('does not render description widget when absent', (
      tester,
    ) async {
      await tester.pumpWidget(
        _wrap(StringInputWidget(parameter: _makeParam(), onChanged: (_) {})),
      );

      expect(find.text('Some description'), findsNothing);
    });

    testWidgets('calls onChanged with typed text value', (tester) async {
      String? captured;
      await tester.pumpWidget(
        _wrap(
          StringInputWidget(
            parameter: _makeParam(),
            onChanged: (v) => captured = v,
          ),
        ),
      );

      await tester.enterText(find.byType(TextField), 'hello');
      expect(captured, 'hello');
    });

    testWidgets('shows disabled state when isActive is false', (tester) async {
      await tester.pumpWidget(
        _wrap(
          StringInputWidget(
            parameter: _makeParam(),
            onChanged: (_) {},
            isActive: false,
            disabledExplanation: 'Requires Foo to be set.',
          ),
        ),
      );

      var textField = tester.widget<TextField>(find.byType(TextField));
      expect(textField.enabled, isFalse);
    });

    testWidgets('shows explanation text when disabled', (tester) async {
      await tester.pumpWidget(
        _wrap(
          StringInputWidget(
            parameter: _makeParam(),
            onChanged: (_) {},
            isActive: false,
            disabledExplanation: 'Requires Foo to be set.',
          ),
        ),
      );

      expect(find.text('Requires Foo to be set.'), findsOneWidget);
    });

    testWidgets('does not show explanation text when active', (tester) async {
      await tester.pumpWidget(
        _wrap(StringInputWidget(parameter: _makeParam(), onChanged: (_) {})),
      );

      expect(find.text('Requires Foo to be set.'), findsNothing);
    });
  });
}
