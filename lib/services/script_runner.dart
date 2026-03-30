import 'dart:io';

class ScriptResult {
  const ScriptResult({
    required this.exitCode,
    required this.stdout,
    required this.stderr,
  });
  final int exitCode;
  final String stdout;
  final String stderr;

  bool get isSuccess => exitCode == 0;
}

typedef ProcessRunner =
    Future<ProcessResult> Function(
      String executable,
      List<String> arguments, {
      String? workingDirectory,
      bool runInShell,
    });

class ScriptRunner {
  const ScriptRunner({ProcessRunner runProcess = _defaultRunner})
    : _runProcess = runProcess;
  final ProcessRunner _runProcess;

  static Future<ProcessResult> _defaultRunner(
    String executable,
    List<String> arguments, {
    String? workingDirectory,
    bool runInShell = false,
  }) => Process.run(
    executable,
    arguments,
    workingDirectory: workingDirectory,
    runInShell: runInShell,
  );

  Future<ScriptResult> run(
    String executable,
    List<String> args, {
    String? workingDirectory,
    bool runInShell = true,
  }) async {
    try {
      var result = await _runProcess(
        executable,
        args,
        workingDirectory: workingDirectory,
        runInShell: runInShell,
      );

      return ScriptResult(
        exitCode: result.exitCode,
        stdout: result.stdout.toString(),
        stderr: result.stderr.toString(),
      );
    } catch (e) {
      return ScriptResult(exitCode: -1, stdout: '', stderr: e.toString());
    }
  }
}
