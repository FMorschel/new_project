import 'dart:io';

void main(List<String> args) async {
  print('Running flutter create -e with arguments: $args\n');

  var process = await Process.start('flutter', [
    'create',
    '-e',
    ...args,
  ], mode: ProcessStartMode.inheritStdio);

  var exitCode = await process.exitCode;

  print('\nFinished with exit code: $exitCode');
  exit(exitCode);
}
