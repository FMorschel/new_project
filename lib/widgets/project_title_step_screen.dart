import 'package:flutter/material.dart';

import '../models/template_parameter.dart';
import 'parameter_input_widget.dart';

class ProjectTitleStepScreen extends StatefulWidget {
  const ProjectTitleStepScreen({
    required this.parameter,
    required this.onNext,
    this.initialValue,
    super.key,
  });

  final TemplateParameter parameter;
  final ValueChanged<String> onNext;
  final String? initialValue;

  @override
  State<ProjectTitleStepScreen> createState() => _ProjectTitleStepScreenState();
}

class _ProjectTitleStepScreenState extends State<ProjectTitleStepScreen> {
  String? _value;

  @override
  void initState() {
    super.initState();
    _value = widget.initialValue;
  }

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
                onChanged: (v) =>
                    setState(() => _value = v is String ? v : null),
                initialValue: widget.initialValue,
              ),
            ),
          ),
        ),
        const SizedBox(height: 24),
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            FilledButton.icon(
              style: FilledButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  horizontal: 32,
                  vertical: 16,
                ),
              ),
              onPressed: (_value == null || _value!.isEmpty)
                  ? null
                  : () => widget.onNext(_value!),
              icon: const Icon(Icons.arrow_forward),
              label: const Text(
                'Next',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      ],
    ),
  );
}
