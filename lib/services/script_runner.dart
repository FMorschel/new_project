import 'dart:convert';
import 'dart:io';

enum ScriptType {
  dart('.dart'),
  ps1('.ps1'),
  sh('.sh'),
  bat('.bat');

  const ScriptType(this.extension);
  final String extension;

  static ScriptType? fromPath(String path) {
    for (var type in values) {
      if (path.endsWith(type.extension)) return type;
    }
    return null;
  }

  bool get runInShell => switch (this) {
    bat => true,
    dart || ps1 || sh => false,
  };

  (String executable, List<String> arguments) resolve(
    String path,
    List<String> args,
  ) => switch (this) {
    dart => ('dart', ['run', path, ...args]),
    ps1 => ('powershell', ['-File', path, ...args]),
    sh => ('bash', [path, ...args]),
    bat => (path, args),
  };
}

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
    });

class ScriptRunner {
  const ScriptRunner({ProcessRunner runProcess = defaultRunner})
    : _runProcess = runProcess;
  final ProcessRunner _runProcess;

  static Future<ProcessResult> defaultRunner(
    String executable,
    List<String> arguments, {
    String? workingDirectory,
  }) async {
    var type = ScriptType.fromPath(executable);
    if (type == null) {
      throw ArgumentError('Unsupported script type: $executable');
    }
    var (resolvedExecutable, resolvedArguments) = type.resolve(
      executable,
      arguments,
    );

    var result = await Process.start(
      resolvedExecutable,
      resolvedArguments,
      workingDirectory: workingDirectory,
      runInShell: type.runInShell,
    );

    var stdoutFuture = result.stdout.transform(utf8.decoder).join();
    var stderrFuture = result.stderr.transform(utf8.decoder).join();
    var code = await result.exitCode;

    return ProcessResult(
      result.pid,
      code,
      await stdoutFuture,
      await stderrFuture,
    );
  }

  Future<ScriptResult> run(
    String executable,
    List<String> args, {
    String? workingDirectory,
  }) async {
    try {
      var result = await _runProcess(
        executable,
        args,
        workingDirectory: workingDirectory,
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
