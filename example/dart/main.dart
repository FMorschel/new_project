import 'dart:io';

void main(List<String> args) async {
  String? projectName;
  String? projectPath;
  var remainingArgs = <String>[];

  for (var i = 0; i < args.length; i++) {
    if (args[i] == '--project-name' && i + 1 < args.length) {
      projectName = args[++i];
    } else if (args[i] == '--project-path' && i + 1 < args.length) {
      projectPath = args[++i];
    } else {
      remainingArgs.add(args[i]);
    }
  }

  if (projectName == null || projectPath == null) {
    stderr.writeln('Missing --project-name or --project-path.');
    exit(1);
  }

  var directory = '$projectPath${Platform.pathSeparator}$projectName';
  var dartArgs = ['create', ...remainingArgs, directory];

  print('Running: dart ${dartArgs.join(' ')}\n');

  var process = await Process.start(
    'dart',
    dartArgs,
    mode: ProcessStartMode.inheritStdio,
  );

  var exitCode = await process.exitCode;
  print('\nFinished with exit code: $exitCode');
  exit(exitCode);
}
