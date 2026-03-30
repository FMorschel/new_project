import 'package:flutter_test/flutter_test.dart';
import 'package:new_project/services/preferences_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  group('PreferencesService', () {
    late PreferencesService service;

    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      service = await PreferencesService.create();
    });

    test('saves last-used value keyed by <templateName>/<paramKey>', () async {
      await service.saveValue('myTemplate', 'myParam', 'myValue');

      var prefs = await SharedPreferences.getInstance();
      expect(prefs.getString('myTemplate/myParam'), 'myValue');
    });

    test('retrieves last-used value for a given template + key', () async {
      SharedPreferences.setMockInitialValues({
        'myTemplate/myParam': 'savedValue',
      });
      var localService = await PreferencesService.create();

      var value = localService.getValue('myTemplate', 'myParam');
      expect(value, 'savedValue');
    });

    test('projectTitle and projectPath are never saved', () async {
      await service.saveValue('myTemplate', 'projectTitle', 'SuperProject');
      await service.saveValue('myTemplate', 'projectPath', '/my/path');

      var prefs = await SharedPreferences.getInstance();
      expect(prefs.getString('myTemplate/projectTitle'), isNull);
      expect(prefs.getString('myTemplate/projectPath'), isNull);
    });

    test('returns null (no pre-fill) when no saved value exists', () {
      var value = service.getValue('myTemplate', 'unknownParam');
      expect(value, isNull);
    });
  });
}
