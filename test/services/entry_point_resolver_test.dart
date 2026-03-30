import 'package:flutter_test/flutter_test.dart';
import 'package:new_project/services/entry_point_resolver.dart';

EntryPointResolver _resolver({
  required bool isWindows,
  Set<String> existingFiles = const {},
}) => EntryPointResolver(
  isWindows: isWindows,
  fileExists: (path) => existingFiles.any((f) => path.endsWith(f)),
);

void main() {
  group('EntryPointResolver — Windows', () {
    test('resolves .dart first when it exists', () {
      var resolver = _resolver(
        isWindows: true,
        existingFiles: {'main.dart', 'main.ps1', 'main.bat', 'main.sh'},
      );
      expect(resolver.resolve('/template'), endsWith('main.dart'));
    });

    test('resolves .ps1 before .bat and .sh when .dart is absent', () {
      var resolver = _resolver(
        isWindows: true,
        existingFiles: {'main.ps1', 'main.bat', 'main.sh'},
      );
      expect(resolver.resolve('/template'), endsWith('main.ps1'));
    });

    test('resolves .bat before .sh when .dart and .ps1 are absent', () {
      var resolver = _resolver(
        isWindows: true,
        existingFiles: {'main.bat', 'main.sh'},
      );
      expect(resolver.resolve('/template'), endsWith('main.bat'));
    });

    test('resolves .sh when it is the only match', () {
      var resolver = _resolver(isWindows: true, existingFiles: {'main.sh'});
      expect(resolver.resolve('/template'), endsWith('main.sh'));
    });
  });

  group('EntryPointResolver — macOS/Linux', () {
    test('resolves .dart first when it exists', () {
      var resolver = _resolver(
        isWindows: false,
        existingFiles: {'main.dart', 'main.sh', 'main.ps1', 'main.bat'},
      );
      expect(resolver.resolve('/template'), endsWith('main.dart'));
    });

    test('resolves .sh before .ps1 and .bat when .dart is absent', () {
      var resolver = _resolver(
        isWindows: false,
        existingFiles: {'main.sh', 'main.ps1', 'main.bat'},
      );
      expect(resolver.resolve('/template'), endsWith('main.sh'));
    });

    test('resolves .ps1 before .bat when .dart and .sh are absent', () {
      var resolver = _resolver(
        isWindows: false,
        existingFiles: {'main.ps1', 'main.bat'},
      );
      expect(resolver.resolve('/template'), endsWith('main.ps1'));
    });

    test('resolves .bat when it is the only match', () {
      var resolver = _resolver(isWindows: false, existingFiles: {'main.bat'});
      expect(resolver.resolve('/template'), endsWith('main.bat'));
    });
  });

  group('EntryPointResolver — common behaviour', () {
    test('throws EntryPointNotFoundException when no main.* file is found', () {
      var resolver = _resolver(isWindows: true, existingFiles: {});
      expect(
        () => resolver.resolve('/template'),
        throwsA(isA<EntryPointNotFoundException>()),
      );
    });

    test('returns the first match and does not continue searching', () {
      // Only .sh exists on Windows — should still find it (last in order)
      // but .ps1 and .bat are absent, confirming first-match semantics.
      var resolver = _resolver(isWindows: true, existingFiles: {'main.sh'});
      expect(resolver.resolve('/template'), endsWith('main.sh'));
    });
  });
}
