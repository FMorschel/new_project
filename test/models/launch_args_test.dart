import 'package:flutter_test/flutter_test.dart';
import 'package:new_project/models/launch_args.dart';

void main() {
  group('LaunchArgs.parse', () {
    test('parses folder path and template name from two args', () {
      var result = LaunchArgs.parse(['/home/user/projects', 'flutter_app']);
      expect(result.folderPath, '/home/user/projects');
      expect(result.templateName, 'flutter_app');
    });

    test('returns null folder and template when args are empty', () {
      var result = LaunchArgs.parse([]);
      expect(result.folderPath, isNull);
      expect(result.templateName, isNull);
    });

    test('returns null folder and template when only one arg is present', () {
      var result = LaunchArgs.parse(['/home/user/projects']);
      expect(result.folderPath, isNull);
      expect(result.templateName, isNull);
    });

    test('ignores extra args beyond the first two', () {
      var result = LaunchArgs.parse(['/path', 'tmpl', 'extra', 'ignored']);
      expect(result.folderPath, '/path');
      expect(result.templateName, 'tmpl');
    });
  });
}
