// ignore_for_file: essential_lints/returning_widgets tests

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:new_project/models/template_parameter.dart';
import 'package:new_project/widgets/boolean_input_widget.dart';
import 'package:new_project/widgets/integer_input_widget.dart';
import 'package:new_project/widgets/multi_options_input_widget.dart';
import 'package:new_project/widgets/num_input_widget.dart';
import 'package:new_project/widgets/parameter_input_widget.dart';
import 'package:new_project/widgets/single_options_input_widget.dart';
import 'package:new_project/widgets/string_input_widget.dart';

Widget _wrap(Widget child) => MaterialApp(home: Scaffold(body: child));

TemplateParameter _param(
  ParameterType type, {
  bool multiSelect = false,
  List<String>? options,
}) => TemplateParameter(
  key: 'k',
  label: 'Label',
  type: type,
  multiSelect: multiSelect,
  options: options,
  required: true,
  passing: const PassingConfig(
    style: PassingStyle.flagSpaceValue,
    flag: '--flag',
  ),
);

void main() {
  group('ParameterInputWidget — widget dispatch', () {
    testWidgets('renders StringInputWidget for type string', (tester) async {
      await tester.pumpWidget(
        _wrap(
          ParameterInputWidget(
            parameter: _param(ParameterType.string),
            onChanged: (_) {},
          ),
        ),
      );
      expect(find.byType(StringInputWidget), findsOneWidget);
    });

    testWidgets('renders IntegerInputWidget for type integer', (tester) async {
      await tester.pumpWidget(
        _wrap(
          ParameterInputWidget(
            parameter: _param(ParameterType.integer),
            onChanged: (_) {},
          ),
        ),
      );
      expect(find.byType(IntegerInputWidget), findsOneWidget);
    });

    testWidgets('renders NumInputWidget for type num', (tester) async {
      await tester.pumpWidget(
        _wrap(
          ParameterInputWidget(
            parameter: _param(ParameterType.num),
            onChanged: (_) {},
          ),
        ),
      );
      expect(find.byType(NumInputWidget), findsOneWidget);
    });

    testWidgets('renders BooleanInputWidget for type boolean', (tester) async {
      await tester.pumpWidget(
        _wrap(
          ParameterInputWidget(
            parameter: _param(ParameterType.boolean),
            onChanged: (_) {},
          ),
        ),
      );
      expect(find.byType(BooleanInputWidget), findsOneWidget);
    });

    testWidgets(
      'renders SingleOptionsInputWidget for options with multiSelect false',
      (tester) async {
        await tester.pumpWidget(
          _wrap(
            ParameterInputWidget(
              parameter: _param(ParameterType.options, options: ['A', 'B']),
              onChanged: (_) {},
            ),
          ),
        );
        expect(find.byType(SingleOptionsInputWidget), findsOneWidget);
      },
    );

    testWidgets(
      'renders MultiOptionsInputWidget for options with multiSelect true',
      (tester) async {
        await tester.pumpWidget(
          _wrap(
            ParameterInputWidget(
              parameter: _param(
                ParameterType.options,
                multiSelect: true,
                options: ['A', 'B'],
              ),
              onChanged: (_) {},
            ),
          ),
        );
        expect(find.byType(MultiOptionsInputWidget), findsOneWidget);
      },
    );
  });

  group('ParameterInputWidget — prop forwarding', () {
    testWidgets('forwards isActive and disabledExplanation', (tester) async {
      await tester.pumpWidget(
        _wrap(
          ParameterInputWidget(
            parameter: _param(ParameterType.string),
            onChanged: (_) {},
            isActive: false,
            disabledExplanation: 'Requires Foo.',
          ),
        ),
      );
      expect(find.text('Requires Foo.'), findsOneWidget);
      var tf = tester.widget<TextField>(find.byType(TextField));
      expect(tf.enabled, isFalse);
    });

    testWidgets('forwards String? value from string input via onChanged', (
      tester,
    ) async {
      Object? captured;
      await tester.pumpWidget(
        _wrap(
          ParameterInputWidget(
            parameter: _param(ParameterType.string),
            onChanged: (v) => captured = v,
          ),
        ),
      );
      await tester.enterText(find.byType(TextField), 'hello');
      expect(captured, 'hello');
    });

    testWidgets('forwards bool value from boolean input via onChanged', (
      tester,
    ) async {
      Object? captured;
      await tester.pumpWidget(
        _wrap(
          ParameterInputWidget(
            parameter: _param(ParameterType.boolean),
            onChanged: (v) => captured = v,
          ),
        ),
      );
      await tester.tap(find.byType(Checkbox));
      expect(captured, isTrue);
    });

    testWidgets(
      'forwards List<String> value from multi-options input via onChanged',
      (tester) async {
        Object? captured;
        await tester.pumpWidget(
          _wrap(
            ParameterInputWidget(
              parameter: _param(
                ParameterType.options,
                multiSelect: true,
                options: ['X', 'Y'],
              ),
              onChanged: (v) => captured = v,
            ),
          ),
        );
        await tester.tap(find.byType(OutlinedButton));
        await tester.pumpAndSettle();
        await tester.tap(find.text('X'));
        expect(captured, ['X']);
      },
    );
  });
}
