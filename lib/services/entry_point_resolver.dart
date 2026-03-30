import 'dart:io';

import 'package:path/path.dart' as p;

class EntryPointNotFoundException implements Exception {
  const EntryPointNotFoundException(this.templateDir);
  final String templateDir;

  @override
  String toString() {
    var name = p.basename(templateDir);
    return "No entry point found in template '$name'.";
  }
}

class EntryPointResolver {
  EntryPointResolver({bool? isWindows, bool Function(String path)? fileExists})
    : _isWindows = isWindows ?? Platform.isWindows,
      _fileExists = fileExists ?? ((path) => File(path).existsSync());

  final bool _isWindows;
  final bool Function(String path) _fileExists;

  static const _windowsOrder = ['.dart', '.ps1', '.bat', '.sh'];
  static const _unixOrder = ['.dart', '.sh', '.ps1', '.bat'];

  String resolve(String templateDir) {
    var extensions = _isWindows ? _windowsOrder : _unixOrder;
    for (var ext in extensions) {
      var path = p.join(templateDir, 'main$ext');
      if (_fileExists(path)) return path;
    }
    throw EntryPointNotFoundException(templateDir);
  }
}
