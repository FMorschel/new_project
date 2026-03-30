// ignore_for_file: essential_lints/returning_widgets previews

import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';
import '../models/template_parameter.dart';
import '../widgets/string_input_widget.dart';

const _param = TemplateParameter(
  key: 'name',
  label: 'Project Name',
  description: 'The name of the new project.',
  type: ParameterType.string,
  required: true,
  passing: PassingConfig(style: PassingStyle.flagSpaceValue, flag: '--name'),
);

void _noOp(String? _) {}

@Preview(name: 'Active – empty')
Widget stringInputActive() => const MaterialApp(
  home: Scaffold(
    body: Padding(
      padding: EdgeInsets.all(16),
      child: StringInputWidget(parameter: _param, onChanged: _noOp),
    ),
  ),
);

@Preview(name: 'Active – pre-filled')
Widget stringInputPrefilled() => const MaterialApp(
  home: Scaffold(
    body: Padding(
      padding: EdgeInsets.all(16),
      child: StringInputWidget(
        parameter: _param,
        onChanged: _noOp,
        initialValue: 'my_awesome_app',
      ),
    ),
  ),
);

@Preview(name: 'Disabled')
Widget stringInputDisabled() => const MaterialApp(
  home: Scaffold(
    body: Padding(
      padding: EdgeInsets.all(16),
      child: StringInputWidget(
        parameter: _param,
        onChanged: _noOp,
        isActive: false,
        disabledExplanation: "Requires 'Platform' to be set.",
      ),
    ),
  ),
);
