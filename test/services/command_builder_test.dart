import 'package:flutter_test/flutter_test.dart';
import 'package:new_project/models/template_parameter.dart';
import 'package:new_project/services/command_builder.dart';

void main() {
  group('CommandBuilder', () {
    test('flag style — flag present when true, omitted when false', () {
      var param = const TemplateParameter(
        key: 'verbose',
        label: 'Verbose',
        type: ParameterType.boolean,
        required: false,
        passing: PassingConfig(style: PassingStyle.flag, flag: '--verbose'),
      );

      expect(CommandBuilder.buildArguments([param], {'verbose': true}), [
        '--verbose',
      ]);
      expect(
        CommandBuilder.buildArguments([param], {'verbose': false}),
        isEmpty,
      );
    });

    test('flag_space_value style — --name value', () {
      var param = const TemplateParameter(
        key: 'name',
        label: 'Name',
        type: ParameterType.string,
        required: true,
        passing: PassingConfig(
          style: PassingStyle.flagSpaceValue,
          flag: '--name',
        ),
      );

      expect(CommandBuilder.buildArguments([param], {'name': 'my_app'}), [
        '--name',
        'my_app',
      ]);
    });

    test('flag_equals_value style — --name=value', () {
      var param = const TemplateParameter(
        key: 'name',
        label: 'Name',
        type: ParameterType.string,
        required: true,
        passing: PassingConfig(
          style: PassingStyle.flagEqualsValue,
          flag: '--name',
        ),
      );

      expect(CommandBuilder.buildArguments([param], {'name': 'my_app'}), [
        '--name=my_app',
      ]);
    });

    test('positional style — bare value in array order', () {
      var param1 = const TemplateParameter(
        key: 'p1',
        label: 'P1',
        type: ParameterType.string,
        required: true,
        passing: PassingConfig(style: PassingStyle.positional),
      );
      var param2 = const TemplateParameter(
        key: 'p2',
        label: 'P2',
        type: ParameterType.string,
        required: true,
        passing: PassingConfig(style: PassingStyle.positional),
      );

      expect(
        CommandBuilder.buildArguments(
          [param1, param2],
          {'p1': 'value1', 'p2': 'value2'},
        ),
        ['value1', 'value2'],
      );
    });

    test('skipped (null) parameters are omitted entirely', () {
      var param = const TemplateParameter(
        key: 'name',
        label: 'Name',
        type: ParameterType.string,
        required: false,
        passing: PassingConfig(
          style: PassingStyle.flagSpaceValue,
          flag: '--name',
        ),
      );

      expect(CommandBuilder.buildArguments([param], {'name': null}), isEmpty);
      expect(CommandBuilder.buildArguments([param], {}), isEmpty);
    });

    test('multi-select with default separator — android ios', () {
      var param = const TemplateParameter(
        key: 'platforms',
        label: 'Platforms',
        type: ParameterType.options,
        multiSelect: true,
        required: false,
        passing: PassingConfig(
          style: PassingStyle.positional,
        ), // Default separator is ' '.
      );

      expect(
        CommandBuilder.buildArguments(
          [param],
          {
            'platforms': ['android', 'ios'],
          },
        ),
        ['android ios'],
      );
    });

    test('multi-select with "," separator — android,ios', () {
      var param = const TemplateParameter(
        key: 'platforms',
        label: 'Platforms',
        type: ParameterType.options,
        multiSelect: true,
        required: false,
        passing: PassingConfig(style: PassingStyle.positional, separator: ','),
      );

      expect(
        CommandBuilder.buildArguments(
          [param],
          {
            'platforms': ['android', 'ios'],
          },
        ),
        ['android,ios'],
      );
    });

    test('multi-select with separator + prefix + suffix — [android,ios]', () {
      var param = const TemplateParameter(
        key: 'platforms',
        label: 'Platforms',
        type: ParameterType.options,
        multiSelect: true,
        required: false,
        passing: PassingConfig(
          style: PassingStyle.positional,
          separator: ',',
          prefix: '[',
          suffix: ']',
        ),
      );

      expect(
        CommandBuilder.buildArguments(
          [param],
          {
            'platforms': ['android', 'ios'],
          },
        ),
        ['[android,ios]'],
      );
    });

    test('multi-select with no selections — parameter omitted entirely', () {
      var param = const TemplateParameter(
        key: 'platforms',
        label: 'Platforms',
        type: ParameterType.options,
        multiSelect: true,
        required: false,
        passing: PassingConfig(
          style: PassingStyle.flagSpaceValue,
          flag: '--platforms',
        ),
      );

      expect(
        CommandBuilder.buildArguments([param], {'platforms': []}),
        isEmpty,
      );
    });

    test('parameter with unmet dependsOn condition is omitted entirely', () {
      var param1 = const TemplateParameter(
        key: 'use_db',
        label: 'Use DB',
        type: ParameterType.boolean,
        required: false,
        passing: PassingConfig(style: PassingStyle.flag, flag: '--use-db'),
      );
      var param2 = const TemplateParameter(
        key: 'db_name',
        label: 'DB Name',
        type: ParameterType.string,
        required: false,
        passing: PassingConfig(
          style: PassingStyle.flagSpaceValue,
          flag: '--db-name',
        ),
        dependsOn: [
          DependsOnCondition(key: 'use_db', op: DependsOnOp.eq, value: 'true'),
        ],
      );

      expect(
        CommandBuilder.buildArguments(
          [param1, param2],
          {'use_db': false, 'db_name': 'mysql'},
        ),
        isEmpty, // Use_db is false, db_name is omitted due to unmet condition.
      );

      expect(
        CommandBuilder.buildArguments(
          [param1, param2],
          {'use_db': true, 'db_name': 'mysql'},
        ),
        ['--use-db', '--db-name', 'mysql'],
      );
    });

    test('all conditions in dependsOn are AND-ed', () {
      var pDepends = const TemplateParameter(
        key: 'target',
        label: 'Target',
        type: ParameterType.string,
        required: false,
        passing: PassingConfig(style: PassingStyle.positional),
        dependsOn: [
          DependsOnCondition(key: 'cond1', op: DependsOnOp.set),
          DependsOnCondition(key: 'cond2', op: DependsOnOp.eq, value: 'yes'),
        ],
      );

      // Both met.
      expect(
        CommandBuilder.buildArguments(
          [pDepends],
          {'cond1': 'set', 'cond2': 'yes', 'target': 'result'},
        ),
        ['result'],
      );

      // Only one met.
      expect(
        CommandBuilder.buildArguments(
          [pDepends],
          {'cond1': 'set', 'target': 'result'},
        ), // Cond2 not set/not yes.
        isEmpty,
      );
    });

    test('projectPath is always included', () {
      var param = const TemplateParameter(
        key: 'projectPath',
        label: 'Project Path',
        type: ParameterType.string,
        required: true,
        passing: PassingConfig(style: PassingStyle.positional),
      );

      expect(
        CommandBuilder.buildArguments([param], {'projectPath': '/some/path'}),
        ['/some/path'],
      );
    });
  });
}
