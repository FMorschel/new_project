// ignore_for_file: essential_lints/returning_widgets previews

import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';
import '../models/template_parameter.dart';
import '../widgets/multi_options_input_widget.dart';

const TemplateParameter _param = TemplateParameter(
  key: 'platforms',
  label: 'Target Platforms',
  type: ParameterType.options,
  options: ['Android', 'iOS', 'Web', 'Desktop'],
  multiSelect: true,
  required: true,
  passing: PassingConfig(
    style: PassingStyle.flagSpaceValue,
    flag: '--platforms',
  ),
);

void _noOp(List<String> _) {}

@Preview(name: 'No selection')
Widget multiOptionsNoSelection() => const MaterialApp(
  home: Scaffold(
    body: Padding(
      padding: EdgeInsets.all(16),
      child: MultiOptionsInputWidget(parameter: _param, onChanged: _noOp),
    ),
  ),
);

@Preview(name: 'With selections')
Widget multiOptionsWithSelections() => const MaterialApp(
  home: Scaffold(
    body: Padding(
      padding: EdgeInsets.all(16),
      child: MultiOptionsInputWidget(
        parameter: _param,
        onChanged: _noOp,
        initialValue: ['Android', 'iOS'],
      ),
    ),
  ),
);

@Preview(name: 'Disabled')
Widget multiOptionsDisabled() => const MaterialApp(
  home: Scaffold(
    body: Padding(
      padding: EdgeInsets.all(16),
      child: MultiOptionsInputWidget(
        parameter: _param,
        onChanged: _noOp,
        isActive: false,
        disabledExplanation: "Requires 'Project Type' to be set.",
      ),
    ),
  ),
);
