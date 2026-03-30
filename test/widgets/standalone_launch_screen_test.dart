// ignore_for_file: essential_lints/returning_widgets tests

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:new_project/widgets/standalone_launch_screen.dart';

Widget _wrap(Widget child) => MaterialApp(home: Scaffold(body: child));

const _templates = ['flutter_clean', 'dart_cli', 'web_app'];

Finder get _continueButton => find.widgetWithText(ElevatedButton, 'Continue');
Finder get _pickFolderButton =>
    find.widgetWithText(OutlinedButton, 'Pick Folder');

void main() {
  group('StandaloneLaunchScreen', () {
    testWidgets('folder picker button is shown', (tester) async {
      await tester.pumpWidget(
        _wrap(
          StandaloneLaunchScreen(
            templates: _templates,
            templatePaths: const {},
            onContinue: (_, _) {},
            pickFolder: () async => null,
          ),
        ),
      );

      expect(_pickFolderButton, findsOneWidget);
    });

    testWidgets('template list shows all discovered templates', (tester) async {
      await tester.pumpWidget(
        _wrap(
          StandaloneLaunchScreen(
            templates: _templates,
            templatePaths: const {},
            onContinue: (_, _) {},
            pickFolder: () async => null,
          ),
        ),
      );

      expect(find.text('flutter_clean'), findsOneWidget);
      expect(find.text('dart_cli'), findsOneWidget);
      expect(find.text('web_app'), findsOneWidget);
    });

    testWidgets(
      'Continue is disabled when neither folder nor template selected',
      (tester) async {
        await tester.pumpWidget(
          _wrap(
            StandaloneLaunchScreen(
              templates: _templates,
              templatePaths: const {},
              onContinue: (_, _) {},
              pickFolder: () async => null,
            ),
          ),
        );

        expect(
          tester.widget<ElevatedButton>(_continueButton).onPressed,
          isNull,
        );
      },
    );

    testWidgets('Continue is disabled when only a folder is selected', (
      tester,
    ) async {
      await tester.pumpWidget(
        _wrap(
          StandaloneLaunchScreen(
            templates: _templates,
            templatePaths: const {},
            onContinue: (_, _) {},
            pickFolder: () async => '/home/user/projects',
          ),
        ),
      );

      await tester.tap(_pickFolderButton);
      await tester.pumpAndSettle();

      expect(tester.widget<ElevatedButton>(_continueButton).onPressed, isNull);
    });

    testWidgets('Continue is disabled when only a template is selected', (
      tester,
    ) async {
      await tester.pumpWidget(
        _wrap(
          StandaloneLaunchScreen(
            templates: _templates,
            templatePaths: const {},
            onContinue: (_, _) {},
            pickFolder: () async => null,
          ),
        ),
      );

      await tester.tap(find.text('dart_cli'));
      await tester.pump();

      expect(tester.widget<ElevatedButton>(_continueButton).onPressed, isNull);
    });

    testWidgets('selecting a template and folder enables Continue', (
      tester,
    ) async {
      await tester.pumpWidget(
        _wrap(
          StandaloneLaunchScreen(
            templates: _templates,
            templatePaths: const {},
            onContinue: (_, _) {},
            pickFolder: () async => '/home/user/projects',
          ),
        ),
      );

      await tester.tap(_pickFolderButton);
      await tester.pumpAndSettle();

      await tester.tap(find.text('flutter_clean'));
      await tester.pump();

      expect(
        tester.widget<ElevatedButton>(_continueButton).onPressed,
        isNotNull,
      );
    });

    testWidgets('Continue calls onContinue with selected folder and template', (
      tester,
    ) async {
      String? capturedFolder;
      String? capturedTemplate;

      await tester.pumpWidget(
        _wrap(
          StandaloneLaunchScreen(
            templates: _templates,
            templatePaths: const {},
            onContinue: (folder, template) {
              capturedFolder = folder;
              capturedTemplate = template;
            },
            pickFolder: () async => '/home/user/projects',
          ),
        ),
      );

      await tester.tap(_pickFolderButton);
      await tester.pumpAndSettle();

      await tester.tap(find.text('dart_cli'));
      await tester.pump();

      await tester.tap(_continueButton);

      expect(capturedFolder, '/home/user/projects');
      expect(capturedTemplate, 'dart_cli');
    });
  });
}
