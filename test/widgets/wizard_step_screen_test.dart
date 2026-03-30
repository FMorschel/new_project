// ignore_for_file: essential_lints/returning_widgets tests

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:new_project/models/template_parameter.dart';
import 'package:new_project/widgets/boolean_input_widget.dart';
import 'package:new_project/widgets/integer_input_widget.dart';
import 'package:new_project/widgets/multi_options_input_widget.dart';
import 'package:new_project/widgets/num_input_widget.dart';
import 'package:new_project/widgets/single_options_input_widget.dart';
import 'package:new_project/widgets/string_input_widget.dart';
import 'package:new_project/widgets/wizard_step_screen.dart';

Widget _wrap(Widget child) => MaterialApp(home: Scaffold(body: child));

TemplateParameter _stringParam({bool required = true}) => TemplateParameter(
  key: 'name',
  label: 'Project Name',
  description: 'Name of the new project.',
  type: ParameterType.string,
  required: required,
  passing: const PassingConfig(
    style: PassingStyle.flagSpaceValue,
    flag: '--name',
  ),
);

TemplateParameter _param(
  ParameterType type, {
  bool multiSelect = false,
  List<String>? options,
  bool required = true,
}) => TemplateParameter(
  key: 'k',
  label: 'My Param',
  type: type,
  multiSelect: multiSelect,
  options: options,
  required: required,
  passing: const PassingConfig(
    style: PassingStyle.flagSpaceValue,
    flag: '--flag',
  ),
);

Finder get _nextButton => find.widgetWithText(ElevatedButton, 'Next');
Finder get _createButton => find.widgetWithText(ElevatedButton, 'Create');
Finder get _backButton => find.widgetWithText(TextButton, 'Back');
Finder get _skipButton => find.widgetWithText(TextButton, 'Skip');
Finder get _skipOptionalButton =>
    find.widgetWithText(TextButton, 'Skip Optional');

void main() {
  group('WizardStepScreen — content', () {
    testWidgets('renders parameter label', (tester) async {
      await tester.pumpWidget(
        _wrap(
          WizardStepScreen(
            parameter: _stringParam(),
            onNext: (_) {},
            onBack: () {},
          ),
        ),
      );
      expect(find.text('Project Name'), findsAtLeastNWidgets(1));
    });

    testWidgets('renders parameter description when present', (tester) async {
      await tester.pumpWidget(
        _wrap(
          WizardStepScreen(
            parameter: _stringParam(),
            onNext: (_) {},
            onBack: () {},
          ),
        ),
      );
      expect(find.text('Name of the new project.'), findsOneWidget);
    });

    testWidgets('renders StringInputWidget for type string', (tester) async {
      await tester.pumpWidget(
        _wrap(
          WizardStepScreen(
            parameter: _param(ParameterType.string),
            onNext: (_) {},
            onBack: () {},
          ),
        ),
      );
      expect(find.byType(StringInputWidget), findsOneWidget);
    });

    testWidgets('renders IntegerInputWidget for type integer', (tester) async {
      await tester.pumpWidget(
        _wrap(
          WizardStepScreen(
            parameter: _param(ParameterType.integer),
            onNext: (_) {},
            onBack: () {},
          ),
        ),
      );
      expect(find.byType(IntegerInputWidget), findsOneWidget);
    });

    testWidgets('renders NumInputWidget for type num', (tester) async {
      await tester.pumpWidget(
        _wrap(
          WizardStepScreen(
            parameter: _param(ParameterType.num),
            onNext: (_) {},
            onBack: () {},
          ),
        ),
      );
      expect(find.byType(NumInputWidget), findsOneWidget);
    });

    testWidgets('renders BooleanInputWidget for type boolean', (tester) async {
      await tester.pumpWidget(
        _wrap(
          WizardStepScreen(
            parameter: _param(ParameterType.boolean),
            onNext: (_) {},
            onBack: () {},
          ),
        ),
      );
      expect(find.byType(BooleanInputWidget), findsOneWidget);
    });

    testWidgets(
      'renders SingleOptionsInputWidget for options multiSelect false',
      (tester) async {
        await tester.pumpWidget(
          _wrap(
            WizardStepScreen(
              parameter: _param(ParameterType.options, options: ['A', 'B']),
              onNext: (_) {},
              onBack: () {},
            ),
          ),
        );
        expect(find.byType(SingleOptionsInputWidget), findsOneWidget);
      },
    );

    testWidgets(
      'renders MultiOptionsInputWidget for options multiSelect true',
      (tester) async {
        await tester.pumpWidget(
          _wrap(
            WizardStepScreen(
              parameter: _param(
                ParameterType.options,
                multiSelect: true,
                options: ['A', 'B'],
              ),
              onNext: (_) {},
              onBack: () {},
            ),
          ),
        );
        expect(find.byType(MultiOptionsInputWidget), findsOneWidget);
      },
    );
  });

  group('WizardStepScreen — Next button', () {
    testWidgets('is disabled when field is empty and required is true', (
      tester,
    ) async {
      await tester.pumpWidget(
        _wrap(
          WizardStepScreen(
            parameter: _stringParam(),
            onNext: (_) {},
            onBack: () {},
          ),
        ),
      );
      expect(tester.widget<ElevatedButton>(_nextButton).onPressed, isNull);
    });

    testWidgets('is enabled when field has a value', (tester) async {
      await tester.pumpWidget(
        _wrap(
          WizardStepScreen(
            parameter: _stringParam(),
            onNext: (_) {},
            onBack: () {},
          ),
        ),
      );
      await tester.enterText(find.byType(TextField), 'hello');
      await tester.pump();
      expect(tester.widget<ElevatedButton>(_nextButton).onPressed, isNotNull);
    });

    testWidgets('calls onNext with current value when tapped', (tester) async {
      Object? captured;
      await tester.pumpWidget(
        _wrap(
          WizardStepScreen(
            parameter: _stringParam(),
            onNext: (v) => captured = v,
            onBack: () {},
          ),
        ),
      );
      await tester.enterText(find.byType(TextField), 'myapp');
      await tester.pump();
      await tester.tap(_nextButton);
      expect(captured, 'myapp');
    });

    testWidgets('shows Create on the last step', (tester) async {
      await tester.pumpWidget(
        _wrap(
          WizardStepScreen(
            parameter: _stringParam(),
            onNext: (_) {},
            onBack: () {},
            isLastStep: true,
            initialValue: 'filled',
          ),
        ),
      );
      expect(_createButton, findsOneWidget);
      expect(_nextButton, findsNothing);
    });
  });

  group('WizardStepScreen — Skip button', () {
    testWidgets('is visible when required is false', (tester) async {
      await tester.pumpWidget(
        _wrap(
          WizardStepScreen(
            parameter: _stringParam(required: false),
            onNext: (_) {},
            onBack: () {},
          ),
        ),
      );
      expect(_skipButton, findsOneWidget);
    });

    testWidgets('is not visible when required is true', (tester) async {
      await tester.pumpWidget(
        _wrap(
          WizardStepScreen(
            parameter: _stringParam(),
            onNext: (_) {},
            onBack: () {},
          ),
        ),
      );
      expect(_skipButton, findsNothing);
    });

    testWidgets('clears the current value and calls onNext with null', (
      tester,
    ) async {
      Object? captured = 'sentinel';
      await tester.pumpWidget(
        _wrap(
          WizardStepScreen(
            parameter: _stringParam(required: false),
            onNext: (v) => captured = v,
            onBack: () {},
            initialValue: 'something',
          ),
        ),
      );
      await tester.tap(_skipButton);
      expect(captured, isNull);
    });
  });

  group('WizardStepScreen — Skip Optional button', () {
    testWidgets('is visible when allRemainingOptional is true', (tester) async {
      await tester.pumpWidget(
        _wrap(
          WizardStepScreen(
            parameter: _stringParam(required: false),
            onNext: (_) {},
            onBack: () {},
            allRemainingOptional: true,
            onSkipAllOptional: () {},
          ),
        ),
      );
      expect(_skipOptionalButton, findsOneWidget);
    });

    testWidgets('is not visible when allRemainingOptional is false', (
      tester,
    ) async {
      await tester.pumpWidget(
        _wrap(
          WizardStepScreen(
            parameter: _stringParam(required: false),
            onNext: (_) {},
            onBack: () {},
          ),
        ),
      );
      expect(_skipOptionalButton, findsNothing);
    });

    testWidgets('calls onSkipAllOptional when tapped', (tester) async {
      var called = false;
      await tester.pumpWidget(
        _wrap(
          WizardStepScreen(
            parameter: _stringParam(required: false),
            onNext: (_) {},
            onBack: () {},
            allRemainingOptional: true,
            onSkipAllOptional: () => called = true,
          ),
        ),
      );
      await tester.tap(_skipOptionalButton);
      expect(called, isTrue);
    });
  });

  group('WizardStepScreen — Back button', () {
    testWidgets('calls onBack when tapped', (tester) async {
      var called = false;
      await tester.pumpWidget(
        _wrap(
          WizardStepScreen(
            parameter: _stringParam(),
            onNext: (_) {},
            onBack: () => called = true,
          ),
        ),
      );
      await tester.tap(_backButton);
      expect(called, isTrue);
    });
  });
}
