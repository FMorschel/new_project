// ignore_for_file: essential_lints/returning_widgets, essential_lints/explicit_casts tests

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:new_project/models/template_parameter.dart';
import 'package:new_project/widgets/multi_options_input_widget.dart';

TemplateParameter _makeParam() => const TemplateParameter(
  key: 'myKey',
  label: 'Pick Many',
  type: ParameterType.options,
  options: ['Apple', 'Banana', 'Cherry'],
  multiSelect: true,
  required: true,
  passing: PassingConfig(style: PassingStyle.flagSpaceValue, flag: '--fruits'),
);

Widget _wrap(Widget child) => MaterialApp(home: Scaffold(body: child));

void main() {
  group('MultiOptionsInputWidget', () {
    testWidgets('renders all options as checkbox list when opened', (
      tester,
    ) async {
      await tester.pumpWidget(
        _wrap(
          MultiOptionsInputWidget(parameter: _makeParam(), onChanged: (_) {}),
        ),
      );

      await tester.tap(find.byType(OutlinedButton));
      await tester.pumpAndSettle();

      expect(find.text('Apple'), findsOneWidget);
      expect(find.text('Banana'), findsOneWidget);
      expect(find.text('Cherry'), findsOneWidget);
      expect(find.byType(CheckboxListTile), findsNWidgets(3));
    });

    testWidgets('typing in search field filters the option list', (
      tester,
    ) async {
      await tester.pumpWidget(
        _wrap(
          MultiOptionsInputWidget(parameter: _makeParam(), onChanged: (_) {}),
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

    testWidgets('multiple items can be selected simultaneously', (
      tester,
    ) async {
      await tester.pumpWidget(
        _wrap(
          MultiOptionsInputWidget(parameter: _makeParam(), onChanged: (_) {}),
        ),
      );

      await tester.tap(find.byType(OutlinedButton));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Apple'));
      await tester.pump();
      await tester.tap(find.text('Cherry'));
      await tester.pump();

      var tiles = tester
          .widgetList<CheckboxListTile>(find.byType(CheckboxListTile))
          .toList();
      expect(
        tiles.firstWhere((t) => (t.title! as Text).data == 'Apple').value,
        isTrue,
      );
      expect(
        tiles.firstWhere((t) => (t.title! as Text).data == 'Cherry').value,
        isTrue,
      );
      expect(
        tiles.firstWhere((t) => (t.title! as Text).data == 'Banana').value,
        isFalse,
      );
    });

    testWidgets(
      'closed state shows comma-separated summary of selected values',
      (tester) async {
        await tester.pumpWidget(
          _wrap(
            MultiOptionsInputWidget(parameter: _makeParam(), onChanged: (_) {}),
          ),
        );

        await tester.tap(find.byType(OutlinedButton));
        await tester.pumpAndSettle();
        await tester.tap(find.text('Apple'));
        await tester.pump();
        await tester.tap(find.text('Cherry'));
        await tester.pump();

        await tester.tap(find.byType(OutlinedButton));
        await tester.pumpAndSettle();

        expect(find.text('Apple, Cherry'), findsOneWidget);
      },
    );

    testWidgets('selecting an option calls onChanged with updated list', (
      tester,
    ) async {
      List<String>? captured;
      await tester.pumpWidget(
        _wrap(
          MultiOptionsInputWidget(
            parameter: _makeParam(),
            onChanged: (v) => captured = v,
          ),
        ),
      );

      await tester.tap(find.byType(OutlinedButton));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Banana'));
      expect(captured, ['Banana']);

      await tester.tap(find.text('Apple'));
      expect(captured, ['Apple', 'Banana']);
    });

    testWidgets('deselecting an option calls onChanged with updated list', (
      tester,
    ) async {
      List<String>? captured;
      await tester.pumpWidget(
        _wrap(
          MultiOptionsInputWidget(
            parameter: _makeParam(),
            onChanged: (v) => captured = v,
            initialValue: const ['Apple', 'Banana'],
          ),
        ),
      );

      await tester.tap(find.byType(OutlinedButton));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Apple'));
      expect(captured, ['Banana']);
    });

    testWidgets('shows disabled state when isActive is false', (tester) async {
      await tester.pumpWidget(
        _wrap(
          MultiOptionsInputWidget(
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
          MultiOptionsInputWidget(
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
