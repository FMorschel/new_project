import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'models/launch_args.dart';
import 'services/entry_point_resolver.dart';
import 'services/preferences_service.dart';
import 'services/script_runner.dart';
import 'services/template_loader.dart';
import 'widgets/app_flow.dart';

// ignore: essential_lints/optional_positional_parameters main.
void main([List<String> args = const []]) async {
  WidgetsFlutterBinding.ensureInitialized();
  var prefs = await PreferencesService.create();

  runApp(MainApp(args: LaunchArgs.parse(args), prefs: prefs));
}

class MainApp extends StatelessWidget {
  const MainApp({required this.args, required this.prefs, super.key});

  final LaunchArgs args;
  final PreferencesService prefs;

  @override
  Widget build(BuildContext context) => ChangeNotifierProvider(
    create: (context) {
      var notifier = ValueNotifier(prefs.getThemeMode());
      // ignore: essential_lints/pending_listener disposed
      notifier.addListener(() async {
        await prefs.setThemeMode(notifier.value);
      });
      return notifier;
    },
    builder: (context, _) => MaterialApp(
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.teal),
      ),
      darkTheme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.teal,
          brightness: .dark,
        ),
      ),
      themeMode: context.watch<ValueNotifier<ThemeMode>>().value,
      home: AppFlow(
        initialArgs: args,
        templateLoader: TemplateLoader(),
        entryPointResolver: EntryPointResolver(),
        prefs: prefs,
        scriptRunner: const ScriptRunner(),
        pickFolder: () async => await FilePicker.platform.getDirectoryPath(
          dialogTitle: 'Select Output Folder',
        ),
        onExit: () => exit(0),
      ),
    ),
  );
}
