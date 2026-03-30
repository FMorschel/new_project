import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:new_project/models/launch_args.dart';
import 'package:new_project/services/entry_point_resolver.dart';
import 'package:new_project/services/preferences_service.dart';
import 'package:new_project/services/script_runner.dart';
import 'package:new_project/services/template_loader.dart';
import 'package:new_project/widgets/app_flow.dart';
import 'package:new_project/widgets/project_title_step_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

class FakeTemplateLoader implements TemplateLoader {
  FakeTemplateLoader(this.template);

  final Template template;

  @override
  Future<List<String>> listTemplates() async => ['mock_template'];

  @override
  Future<Template> loadTemplate(String name) async => template;

  @override
  Future<String> getTemplatePath(String name) async => '/fake/templates/$name';
}

class FakeEntryPointResolver implements EntryPointResolver {
  @override
  String resolve(String templateDir) => '$templateDir/main.dart';
}

final class FakeScriptRunner implements ScriptRunner {
  FakeScriptRunner({this.onRun});
  final Future<ScriptResult> Function(String executable, List<String> args)?
  onRun;

  @override
  Future<ScriptResult> run(
    String executable,
    List<String> args, {
    String? workingDirectory,
    bool runInShell = true,
  }) async {
    if (onRun != null) return onRun!(executable, args);
    return const ScriptResult(exitCode: 0, stdout: 'Success', stderr: '');
  }
}

void main() {
  group('AppFlow Integration', () {
    late PreferencesService prefs;

    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      prefs = await PreferencesService.create();
    });

    var template = const Template(
      parameters: [
        TemplateParameter(
          key: 'projectTitle',
          label: 'Project Title',
          description: '',
          type: ParameterType.string,
          required: true,
          passing: PassingConfig(style: PassingStyle.positional),
        ),
        TemplateParameter(
          key: 'projectPath',
          label: 'Project Path',
          description: '',
          type: ParameterType.string,
          required: true,
          passing: PassingConfig(style: PassingStyle.positional),
        ),
        TemplateParameter(
          key: 'someFlag',
          label: 'Some Flag',
          description: '',
          type: ParameterType.boolean,
          required: true,
          passing: PassingConfig(style: PassingStyle.flag),
        ),
      ],
    );

    testWidgets('full happy-path flow with mock template and script runner', (
      tester,
    ) async {
      var exited = false;
      ScriptResult? capturedResult;

      var runner = FakeScriptRunner(
        onRun: (exe, args) async {
          capturedResult = const ScriptResult(
            exitCode: 0,
            stdout: 'Yay',
            stderr: '',
          );
          return capturedResult!;
        },
      );

      await tester.pumpWidget(
        MaterialApp(
          home: AppFlow(
            initialArgs: const LaunchArgs(
              folderPath: '/my/out',
              templateName: 'mock_template',
            ),
            templateLoader: FakeTemplateLoader(template),
            entryPointResolver: FakeEntryPointResolver(),
            prefs: prefs,
            scriptRunner: runner,
            pickFolder: () async => null,
            onExit: () => exited = true,
          ),
        ),
      );

      // Validating Template...
      await tester.pumpAndSettle();

      // We should be on the project title screen.
      expect(find.byType(ProjectTitleStepScreen), findsOneWidget);
      await tester.enterText(find.byType(TextField), 'My Awesome Project');
      await tester.pumpAndSettle();
      await tester.tap(find.widgetWithText(ElevatedButton, 'Next'));
      await tester.pumpAndSettle();

      // We should be on the someFlag step now because projectPath was skipped.
      expect(find.text('Some Flag'), findsWidgets);
      await tester.tap(find.byType(Checkbox)); // Toggle true.
      await tester.pumpAndSettle();
      await tester.tap(find.widgetWithText(ElevatedButton, 'Create'));
      await tester.pumpAndSettle();
      expect(find.text('Project created successfully!'), findsOneWidget);
      expect(capturedResult, isNotNull);
      expect(capturedResult!.exitCode, 0);

      // Verify that "Edit and retry" restores all previously entered values.
      await tester.tap(find.text('Edit and retry'));
      await tester.pumpAndSettle();

      // Back to step 0.
      expect(find.byType(ProjectTitleStepScreen), findsOneWidget);
      expect(find.text('My Awesome Project'), findsOneWidget); // Persisted.

      // Go back to the end so we can press Close.
      await tester.tap(find.widgetWithText(ElevatedButton, 'Next'));
      await tester.pumpAndSettle();
      await tester.tap(find.widgetWithText(ElevatedButton, 'Create'));
      await tester.pumpAndSettle();

      // Close the app.
      await tester.tap(find.widgetWithText(ElevatedButton, 'Close'));
      await tester.pumpAndSettle();
      expect(exited, isTrue);
    });
  });
}
