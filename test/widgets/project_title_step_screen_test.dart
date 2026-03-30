// ignore_for_file: essential_lints/returning_widgets tests

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:new_project/models/template_parameter.dart';
import 'package:new_project/widgets/project_title_step_screen.dart';

Widget _wrap(Widget child) => MaterialApp(home: Scaffold(body: child));

TemplateParameter _projectTitleParam() => const TemplateParameter(
  key: 'projectTitle',
  label: 'Project Name',
  type: ParameterType.string,
  required: true,
  passing: PassingConfig(style: PassingStyle.positional),
);

void main() {
  group('ProjectTitleSt', () {
    testWidgets('always shown as the first step (no Back button)', (
      tester,
    ) async {
      await tester.pumpWidget(
        _wrap(
          ProjectTitleStepScreen(
            parameter: _projectTitleParam(),
            onNext: (_) {},
          ),
        ),
      );

      expect(find.widgetWithText(TextButton, 'Back'), findsNothing);
    });

    testWidgets('no "Skip" button present', (tester) async {
      await tester.pumpWidget(
        _wrap(
          ProjectTitleStepScreen(
            parameter: _projectTitleParam(),
            onNext: (_) {},
          ),
        ),
      );

      expect(find.widgetWithText(TextButton, 'Skip'), findsNothing);
      expect(find.widgetWithText(TextButton, 'Skip Optional'), findsNothing);
    });

    testWidgets('"Next" is disabled when field is empty', (tester) async {
      await tester.pumpWidget(
        _wrap(
          ProjectTitleStepScreen(
            parameter: _projectTitleParam(),
            onNext: (_) {},
          ),
        ),
      );

      var nextButton = tester.widget<ElevatedButton>(
        find.widgetWithText(ElevatedButton, 'Next'),
      );
      expect(nextButton.onPressed, isNull);
    });

    testWidgets(
      '"Next" is enabled when field has value and calls onNext with string',
      (tester) async {
        String? nextValue;
        await tester.pumpWidget(
          _wrap(
            ProjectTitleStepScreen(
              parameter: _projectTitleParam(),
              onNext: (v) => nextValue = v,
            ),
          ),
        );

        await tester.enterText(find.byType(TextField), 'My Awesome Project');
        await tester.pump();

        var nextButton = tester.widget<ElevatedButton>(
          find.widgetWithText(ElevatedButton, 'Next'),
        );
        expect(nextButton.onPressed, isNotNull);

        await tester.tap(find.widgetWithText(ElevatedButton, 'Next'));
        expect(nextValue, 'My Awesome Project');
      },
    );
  });
}
