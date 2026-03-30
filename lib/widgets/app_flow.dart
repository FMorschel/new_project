import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/launch_args.dart';
import '../services/command_builder.dart';
import '../services/depends_on_evaluator.dart';
import '../services/entry_point_resolver.dart';
import '../services/preferences_service.dart';
import '../services/script_runner.dart';
import '../services/template_loader.dart';
import 'depends_on_explanation.dart';
import 'loading_screen.dart';
import 'project_title_step_screen.dart';
import 'result_screen.dart';
import 'standalone_launch_screen.dart';
import 'template_validation_screen.dart';
import 'wizard_step_screen.dart';
import 'wizard_stepper_bar.dart';

class AppFlow extends StatefulWidget {
  const AppFlow({
    required this.initialArgs,
    required this.templateLoader,
    required this.entryPointResolver,
    required this.prefs,
    required this.scriptRunner,
    required this.pickFolder,
    required this.onExit,
    super.key,
  });

  final LaunchArgs initialArgs;
  final TemplateLoader templateLoader;
  final EntryPointResolver entryPointResolver;
  final PreferencesService prefs;
  final ScriptRunner scriptRunner;
  final Future<String?> Function() pickFolder;
  final VoidCallback onExit;

  @override
  State<AppFlow> createState() => _AppFlowState();
}

class _AppFlowState extends State<AppFlow> {
  late LaunchArgs _args;
  Template? _template;
  late String _entryPointPath;

  bool _isValidating = false;
  Future<void>? _validationTask;

  bool _isLoading = false;
  ScriptResult? _result;

  int _currentStepIndex = 0;
  final Map<String, Object?> _answers = {};

  List<String> _availableTemplates = [];
  Map<String, String> _templatePaths = {};

  @override
  void initState() {
    super.initState();
    _args = widget.initialArgs;

    if (_args.templateName != null && _args.folderPath != null) {
      _isValidating = true;
      _validationTask = _validateTemplate();
    } else {
      unawaited(_loadTemplatesList());
    }
  }

  Future<void> _loadTemplatesList() async {
    var list = await widget.templateLoader.listTemplates();
    var paths = <String, String>{};
    for (var name in list) {
      paths[name] = await widget.templateLoader.getTemplatePath(name);
    }
    if (mounted) {
      setState(() {
        _availableTemplates = list;
        _templatePaths = paths;
      });
    }
  }

  void _startValidation() {
    setState(() {
      _isValidating = true;
      _validationTask = _validateTemplate();
    });
  }

  Future<void> _validateTemplate() async {
    var name = _args.templateName ?? '';
    var template = await widget.templateLoader.loadTemplate(name);
    var templatePath = await widget.templateLoader.getTemplatePath(name);
    var entryPoint = widget.entryPointResolver.resolve(templatePath);

    _template = template;
    _entryPointPath = entryPoint;

    // Inject the selected folder path automatically into the answers.
    _answers['projectPath'] = _args.folderPath;
  }

  void _onValidationSuccess() {
    setState(() {
      _isValidating = false;
      _currentStepIndex = 0;
      _prefillCurrentStep();
    });
  }

  void _onValidationClose() {
    // If we fail validation from standalone, we shouldn't necessarily exit.
    if (widget.initialArgs.templateName == null) {
      setState(() {
        _isValidating = false;
        _template = null;
        _args = const LaunchArgs(); // Reset.
      });
    } else {
      widget.onExit();
    }
  }

  List<TemplateParameter> get _visibleSteps =>
      _template!.parameters.where((p) => p.key != 'projectPath').toList();

  void _prefillCurrentStep() {
    if (_template == null) return;
    if (_currentStepIndex >= _visibleSteps.length) return;

    var step = _visibleSteps[_currentStepIndex];
    if (!_answers.containsKey(step.key)) {
      var savedValue = widget.prefs.getValue(_args.templateName!, step.key);
      if (savedValue != null) {
        _answers[step.key] = savedValue;
      }
    }
  }

  void _onStandaloneContinue(String folderPath, String templateName) {
    _args = LaunchArgs(folderPath: folderPath, templateName: templateName);
    _startValidation();
  }

  void _onNextStep(String key, Object? value) {
    _answers[key] = value;
    unawaited(widget.prefs.saveValue(_args.templateName!, key, value));

    if (_currentStepIndex == _visibleSteps.length - 1) {
      unawaited(_runScript());
    } else {
      setState(() {
        _currentStepIndex++;
        _prefillCurrentStep();
      });
    }
  }

  void _onBackStep() {
    if (_currentStepIndex > 0) {
      setState(() {
        _currentStepIndex--;
      });
    }
  }

  void _onSkipAllOptional() {
    unawaited(_runScript());
  }

  void _onNavigateTo(int index) {
    setState(() {
      _currentStepIndex = index;
      _prefillCurrentStep();
    });
  }

  Future<void> _runScript() async {
    setState(() {
      _isLoading = true;
    });

    var args = CommandBuilder.buildArguments(_template!.parameters, _answers);

    var result = await widget.scriptRunner.run(
      _entryPointPath,
      args,
      workingDirectory: _args.folderPath,
    );

    if (mounted) {
      setState(() {
        _isLoading = false;
        _result = result;
      });
    }
  }

  void _onRetry() {
    setState(() {
      _result = null;
      _currentStepIndex = 0;
    });
  }

  @override
  Widget build(BuildContext context) {
    Widget body;
    if (_result != null) {
      body = ResultScreen(
        exitCode: _result!.exitCode,
        stdout: _result!.stdout,
        stderr: _result!.stderr,
        onClose: widget.onExit,
        onRetry: _onRetry,
      );
    } else if (_isLoading) {
      body = const LoadingScreen();
    } else if (_isValidating && _validationTask != null) {
      body = TemplateValidationScreen(
        validationTask: _validationTask!,
        onSuccess: _onValidationSuccess,
        onClose: _onValidationClose,
      );
    } else if (_template == null) {
      body = StandaloneLaunchScreen(
        templates: _availableTemplates,
        templatePaths: _templatePaths,
        pickFolder: widget.pickFolder,
        onContinue: _onStandaloneContinue,
      );
    } else {
      body = Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 250,
            child: WizardStepperBar(
              steps: _visibleSteps,
              currentIndex: _currentStepIndex,
              answers: _answers,
              onNavigateTo: _onNavigateTo,
            ),
          ),
          const VerticalDivider(width: 1),
          Expanded(
            child: _CurrentStepBuilder(
              step: _visibleSteps[_currentStepIndex],
              isLastStep: _currentStepIndex == _visibleSteps.length - 1,
              visibleSteps: _visibleSteps,
              currentStepIndex: _currentStepIndex,
              template: _template!,
              answers: _answers,
              onNextStep: _onNextStep,
              onBackStep: _onBackStep,
              onSkipAllOptional: _onSkipAllOptional,
            ),
          ),
        ],
      );
    }

    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(child: body),
          Positioned(
            top: 16,
            right: 16,
            child: Consumer<ValueNotifier<ThemeMode>>(
              builder: (context, notifier, _) {
                var isDark = notifier.value.isDark(context);
                return IconButton(
                  icon: Icon(isDark ? Icons.light_mode : Icons.dark_mode),
                  onPressed: () {
                    notifier.value = isDark ? ThemeMode.light : ThemeMode.dark;
                  },
                  tooltip: 'Toggle Theme',
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _CurrentStepBuilder extends StatelessWidget {
  const _CurrentStepBuilder({
    required this.step,
    required this.isLastStep,
    required this.visibleSteps,
    required this.currentStepIndex,
    required this.template,
    required this.answers,
    required this.onNextStep,
    required this.onBackStep,
    required this.onSkipAllOptional,
  });

  final TemplateParameter step;
  final bool isLastStep;
  final List<TemplateParameter> visibleSteps;
  final int currentStepIndex;
  final Template template;
  final Map<String, Object?> answers;
  final void Function(String key, Object? value) onNextStep;
  final VoidCallback onBackStep;
  final VoidCallback onSkipAllOptional;

  @override
  Widget build(BuildContext context) {
    var allRemainingOptional = true;
    for (var i = currentStepIndex; i < visibleSteps.length; i++) {
      if (visibleSteps[i].required) {
        allRemainingOptional = false;
        break;
      }
    }

    var isActive = DependsOnEvaluator.evaluate(step, answers);
    var explanation = isActive
        ? null
        : step.dependsOn!
              .map((e) {
                // Find dependent step label.
                var depStep = template.parameters.firstWhere(
                  (p) => p.key == e.key,
                  orElse: () => step,
                );
                return dependsOnExplanation(e, depStep.label);
              })
              .join('\n');

    if (step.key == 'projectTitle') {
      return ProjectTitleStepScreen(
        parameter: step,
        initialValue: answers[step.key]?.toString(),
        onNext: (val) => onNextStep(step.key, val),
      );
    }

    return WizardStepScreen(
      parameter: step,
      initialValue: answers[step.key],
      onNext: (val) => onNextStep(step.key, val),
      onBack: onBackStep,
      isLastStep: isLastStep,
      allRemainingOptional: allRemainingOptional,
      onSkipAllOptional: onSkipAllOptional,
      isActive: isActive,
      disabledExplanation: explanation,
    );
  }
}

extension ThemeModeExtension on ThemeMode {
  bool isDark(BuildContext context) =>
      this == ThemeMode.dark ||
      (this == ThemeMode.system &&
          MediaQuery.platformBrightnessOf(context) == Brightness.dark);
}
