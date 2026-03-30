import 'dart:io';

void main(List<String> args) async {
  print('Running dart create with arguments: $args\n');

  var process = await Process.start('dart', [
    'create',
    ...args,
  ], mode: ProcessStartMode.inheritStdio);

  var exitCode = await process.exitCode;

  print('\nFinished with exit code: $exitCode');
  exit(exitCode);
}
