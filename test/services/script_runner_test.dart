import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:new_project/services/script_runner.dart';

void main() {
  group('ScriptRunner', () {
    test('command is assembled and passed to Process.run', () async {
      String? capturedExecutable;
      List<String>? capturedArgs;
      String? capturedDir;
      bool? capturedRunInShell;

      var runner = ScriptRunner(
        runProcess:
            (
              executable,
              arguments, {
              workingDirectory,
              runInShell = false,
            }) async {
              capturedExecutable = executable;
              capturedArgs = arguments;
              capturedDir = workingDirectory;
              capturedRunInShell = runInShell;
              return ProcessResult(
                0,
                0,
                'success',
                '',
              ); // Pid, exitCode, stdout, stderr.
            },
      );

      var result = await runner.run('git', [
        'status',
      ], workingDirectory: '/path');

      expect(capturedExecutable, 'git');
      expect(capturedArgs, ['status']);
      expect(capturedDir, '/path');
      expect(capturedRunInShell, true);
      expect(result.exitCode, 0);
      expect(result.isSuccess, true);
    });

    test('non-zero exit code surfaces as error result', () async {
      var runner = ScriptRunner(
        runProcess:
            (
              executable,
              arguments, {
              workingDirectory,
              runInShell = false,
            }) async => ProcessResult(0, 1, 'out', 'err'),
      );

      var result = await runner.run('git', ['status']);
      expect(result.exitCode, 1);
      expect(result.isSuccess, false);
    });

    test('stdout and stderr are captured and returned', () async {
      var runner = ScriptRunner(
        runProcess:
            (
              executable,
              arguments, {
              workingDirectory,
              runInShell = false,
            }) async =>
                ProcessResult(0, 0, 'standard output', 'standard error'),
      );

      var result = await runner.run('echo', ['hello']);
      expect(result.exitCode, 0);
      expect(result.isSuccess, true);
      expect(result.stdout, 'standard output');
      expect(result.stderr, 'standard error');
    });

    test('handles Process.run exceptions gracefully', () async {
      var runner = ScriptRunner(
        runProcess:
            (
              executable,
              arguments, {
              workingDirectory,
              runInShell = false,
            }) {
              throw Exception('Process not found');
            },
      );

      var result = await runner.run('unknown_cmd', []);
      expect(result.exitCode, -1);
      expect(result.isSuccess, false);
      expect(result.stderr, contains('Process not found'));
    });
  });
}
