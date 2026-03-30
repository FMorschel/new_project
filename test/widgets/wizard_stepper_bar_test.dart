// ignore_for_file: essential_lints/returning_widgets, essential_lints/explicit_casts tests

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:new_project/models/template_parameter.dart';
import 'package:new_project/widgets/wizard_stepper_bar.dart';

Widget _wrap(Widget child) => MaterialApp(home: Scaffold(body: child));

const _passing = PassingConfig(
  style: PassingStyle.flagSpaceValue,
  flag: '--flag',
);

TemplateParameter _step(String key, String label, {bool required = true}) =>
    TemplateParameter(
      key: key,
      label: label,
      type: ParameterType.string,
      required: required,
      passing: _passing,
    );

final List<TemplateParameter> _steps = [
  _step('a', 'Step A'),
  _step('b', 'Step B'),
  _step('c', 'Step C', required: false),
  _step('d', 'Step D'),
];

ChoiceChip _chipFor(WidgetTester tester, String label) =>
    tester.widget<ChoiceChip>(find.widgetWithText(ChoiceChip, label));

void main() {
  group('WizardStepperBar', () {
    testWidgets('renders all step labels in order', (tester) async {
      await tester.pumpWidget(
        _wrap(
          WizardStepperBar(
            steps: _steps,
            currentIndex: 0,
            answers: const {},
            onNavigateTo: (_) {},
          ),
        ),
      );

      var chips = tester
          .widgetList<ChoiceChip>(find.byType(ChoiceChip))
          .toList();
      expect(chips.length, 4);
      expect((chips.first.label as Text).data, 'Step A');
      expect((chips[1].label as Text).data, 'Step B');
      expect((chips[2].label as Text).data, 'Step C');
      expect((chips[3].label as Text).data, 'Step D');
    });

    testWidgets('current step chip is selected', (tester) async {
      await tester.pumpWidget(
        _wrap(
          WizardStepperBar(
            steps: _steps,
            currentIndex: 1,
            answers: const {'a': 'foo'},
            onNavigateTo: (_) {},
          ),
        ),
      );

      expect(_chipFor(tester, 'Step A').selected, isFalse);
      expect(_chipFor(tester, 'Step B').selected, isTrue);
      expect(_chipFor(tester, 'Step C').selected, isFalse);
      expect(_chipFor(tester, 'Step D').selected, isFalse);
    });

    testWidgets('previous steps are clickable and call onNavigateTo', (
      tester,
    ) async {
      int? navigatedTo;
      await tester.pumpWidget(
        _wrap(
          WizardStepperBar(
            steps: _steps,
            currentIndex: 2,
            answers: const {'a': 'foo', 'b': 'bar'},
            onNavigateTo: (i) => navigatedTo = i,
          ),
        ),
      );

      expect(_chipFor(tester, 'Step A').onSelected, isNotNull);
      expect(_chipFor(tester, 'Step B').onSelected, isNotNull);

      await tester.tap(find.widgetWithText(ChoiceChip, 'Step A'));
      expect(navigatedTo, 0);

      await tester.tap(find.widgetWithText(ChoiceChip, 'Step B'));
      expect(navigatedTo, 1);
    });

    testWidgets(
      'a future step is clickable when all prior required steps are answered',
      (tester) async {
        int? navigatedTo;
        // Current on Step A (index 0); answers has A answered.
        // Step B (index 1) prior required = A → answered → clickable.
        await tester.pumpWidget(
          _wrap(
            WizardStepperBar(
              steps: _steps,
              currentIndex: 0,
              answers: const {'a': 'foo'},
              onNavigateTo: (i) => navigatedTo = i,
            ),
          ),
        );

        expect(_chipFor(tester, 'Step B').onSelected, isNotNull);
        await tester.tap(find.widgetWithText(ChoiceChip, 'Step B'));
        expect(navigatedTo, 1);
      },
    );

    testWidgets(
      'a future step is greyed out when a prior required step is unanswered',
      (tester) async {
        // Current on Step A (index 0); no answers yet.
        // Step B (index 1) prior required = A → not answered → disabled.
        await tester.pumpWidget(
          _wrap(
            WizardStepperBar(
              steps: _steps,
              currentIndex: 0,
              answers: const {},
              onNavigateTo: (_) {},
            ),
          ),
        );

        expect(_chipFor(tester, 'Step B').onSelected, isNull);
        expect(_chipFor(tester, 'Step C').onSelected, isNull);
        expect(_chipFor(tester, 'Step D').onSelected, isNull);
      },
    );

    testWidgets('current step chip is not interactive', (tester) async {
      await tester.pumpWidget(
        _wrap(
          WizardStepperBar(
            steps: _steps,
            currentIndex: 1,
            answers: const {'a': 'foo'},
            onNavigateTo: (_) {},
          ),
        ),
      );

      expect(_chipFor(tester, 'Step B').onSelected, isNull);
    });
  });
}
