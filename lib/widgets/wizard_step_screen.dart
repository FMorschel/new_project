import 'package:flutter/material.dart';

import '../models/template_parameter.dart';
import 'parameter_input_widget.dart';

class WizardStepScreen extends StatefulWidget {
  const WizardStepScreen({
    required this.parameter,
    required this.onNext,
    required this.onBack,
    super.key,
    this.isLastStep = false,
    this.allRemainingOptional = false,
    this.onSkipAllOptional,
    this.initialValue,
    this.isActive = true,
    this.disabledExplanation,
  });

  final TemplateParameter parameter;
  final ValueChanged<Object?> onNext;
  final VoidCallback onBack;
  final bool isLastStep;
  final bool allRemainingOptional;
  final VoidCallback? onSkipAllOptional;
  final Object? initialValue;
  final bool isActive;
  final String? disabledExplanation;

  @override
  State<WizardStepScreen> createState() => _WizardStepScreenState();
}

class _WizardStepScreenState extends State<WizardStepScreen> {
  late Object? _value;

  @override
  void initState() {
    super.initState();
    _value = widget.initialValue;
  }

  bool get _isEmpty {
    var v = _value;
    if (v == null) return true;
    if (v is String) return v.isEmpty;
    if (v is List) return v.isEmpty;
    return false; // Bool is never considered empty.
  }

  bool get _nextEnabled => !widget.parameter.required || !_isEmpty;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(left: 48, top: 48, bottom: 48, right: 120),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: SingleChildScrollView(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 600),
              child: ParameterInputWidget(
                parameter: widget.parameter,
                onChanged: (v) => setState(() => _value = v),
                isActive: widget.isActive,
                disabledExplanation: widget.disabledExplanation,
                initialValue: widget.initialValue,
              ),
            ),
          ),
        ),
        const SizedBox(height: 24),
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            TextButton(
              onPressed: widget.onBack,
              style: TextButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 16,
                ),
              ),
              child: const Text('Back', style: TextStyle(fontSize: 16)),
            ),
            const SizedBox(width: 8),
            if (!widget.parameter.required) ...[
              TextButton(
                onPressed: () => widget.onNext(null),
                style: TextButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 16,
                  ),
                ),
                child: const Text('Skip', style: TextStyle(fontSize: 16)),
              ),
              const SizedBox(width: 8),
            ],
            if (widget.allRemainingOptional) ...[
              TextButton(
                onPressed: widget.onSkipAllOptional,
                style: TextButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 16,
                  ),
                ),
                child: const Text(
                  'Skip Optional',
                  style: TextStyle(fontSize: 16),
                ),
              ),
              const SizedBox(width: 8),
            ],
            FilledButton.icon(
              onPressed: _nextEnabled ? () => widget.onNext(_value) : null,
              style: FilledButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  horizontal: 32,
                  vertical: 16,
                ),
              ),
              icon: Icon(widget.isLastStep ? Icons.check : Icons.arrow_forward),
              label: Text(
                widget.isLastStep ? 'Create' : 'Next',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ],
    ),
  );
}
