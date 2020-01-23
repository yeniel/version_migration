import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:package_info/package_info.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:version_migration/version_migration.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
    mockPackageInfo();
    VersionMigration.reset();
  });

  tearDown(() {

  });

  test('migration reset', () async {
    await givenAFirstMigration();
    await whenResetVersionMigration();
    await whenMigrateAgain();
    expectMigrationIsDoneAgain();
  });

}

bool migration09Done = false;
bool migration10Done = false;

void mockPackageInfo() {
  const MethodChannel('plugins.flutter.io/package_info').setMockMethodCallHandler((MethodCall methodCall) async {
    if (methodCall.method == 'getAll') {
      return <String, dynamic>{
        'appName': 'VersionMigration',
        'packageName': 'VersionMigration',
        'version': '0.0.0',
        'buildNumber': '0'
      };
    }
    return null;
  });
}

givenAFirstMigration() async {
  await VersionMigration.migrateToVersion("0.9", () {});
  await VersionMigration.migrateToVersion("1.0", () {});
}

whenResetVersionMigration() {
  VersionMigration.reset();
}

whenMigrateAgain() async {
  await VersionMigration.migrateToVersion("0.9", () {
    migration09Done = true;
  });

  await VersionMigration.migrateToVersion("1.0", () {
    migration10Done = true;
  });
}

expectMigrationIsDoneAgain() {
  expect(migration09Done, true);
  expect(migration10Done, true);
}