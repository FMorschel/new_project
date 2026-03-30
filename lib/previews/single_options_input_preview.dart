// ignore_for_file: essential_lints/returning_widgets previews

import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';
import '../models/template_parameter.dart';
import '../widgets/single_options_input_widget.dart';

const TemplateParameter _param = TemplateParameter(
  key: 'platform',
  label: 'Target Platform',
  type: ParameterType.options,
  options: ['Android', 'iOS', 'Web', 'Desktop'],
  required: true,
  passing: PassingConfig(
    style: PassingStyle.flagSpaceValue,
    flag: '--platform',
  ),
);

void _noOp(String? _) {}

@Preview(name: 'No selection')
Widget singleOptionsNoSelection() => const MaterialApp(
  home: Scaffold(
    body: Padding(
      padding: EdgeInsets.all(16),
      child: SingleOptionsInputWidget(parameter: _param, onChanged: _noOp),
    ),
  ),
);

@Preview(name: 'With selection')
Widget singleOptionsWithSelection() => const MaterialApp(
  home: Scaffold(
    body: Padding(
      padding: EdgeInsets.all(16),
      child: SingleOptionsInputWidget(
        parameter: _param,
        onChanged: _noOp,
        initialValue: 'Android',
      ),
    ),
  ),
);

@Preview(name: 'Disabled')
Widget singleOptionsDisabled() => const MaterialApp(
  home: Scaffold(
    body: Padding(
      padding: EdgeInsets.all(16),
      child: SingleOptionsInputWidget(
        parameter: _param,
        onChanged: _noOp,
        isActive: false,
        disabledExplanation: "Requires 'Project Type' to be set.",
      ),
    ),
  ),
);
