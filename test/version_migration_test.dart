import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:version_migration/version_migration.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
    mockPackageInfo();
    VersionMigration.reset();
    reset();
  });

  tearDown(() {

  });

  group('migration reset', () {
    test('migration reset', () async {
      await whenRunsFirstMigration();
      await whenResetVersionMigration();
      await whenRunsFirstMigration();
      expectMigrationIsDone();
    });
  });

  group('migrateToVersion method', () {
    test('migrate on first run', () async {
      await whenRunsFirstMigration();
      expectMigrationIsDone();
    });

    test('migrates once', () async {
      await whenRunsTwoMigrationOfSameVersion();
      expectMigrationIsNotDone();
    });

    test('migrates in natural sort order', () async {
      await whenRunsMigrationsInWrongOrder();
      expectOnlyOrderedMigrationsAreDone();
    });
  });

  group('applicationUpdate method', () {
    test('runs application update once', () async {
      whenRunsTwoApplicationUpdatesCalls();
      expectOnlyRunsFirstApplicationUpdate();
    });
  });

}

bool migration090 = false;
bool migration100 = false;
bool migration0100 = false;
bool migration010 = false;
bool applicationUpdate = false;

void mockPackageInfo() {
  const MethodChannel('plugins.flutter.io/package_info').setMockMethodCallHandler((MethodCall methodCall) async {
    if (methodCall.method == 'getAll') {
      return <String, dynamic>{
        'appName': 'VersionMigration',
        'packageName': 'VersionMigration',
        'version': '1.0.0',
        'buildNumber': '0'
      };
    }
    return null;
  });
}

reset() {
  migration090 = false;
  migration100 = false;
  migration0100 = false;
  migration010 = false;
  applicationUpdate = false;
}

whenRunsFirstMigration() async {
  await VersionMigration.migrateToVersion("0.9.0", () {
    migration090 = true;
  });
  await VersionMigration.migrateToVersion("1.0.0", () {
    migration100 = true;
  });
}

whenRunsTwoMigrationOfSameVersion() async {
  await whenRunsFirstMigration();
  reset();
  await whenRunsFirstMigration();
}

whenRunsMigrationsInWrongOrder() async {
  await VersionMigration.migrateToVersion("0.9.0", () {
    migration090 = true;
  });

  await VersionMigration.migrateToVersion("0.1.0", () {
    migration010 = true;
  });

  await VersionMigration.migrateToVersion("0.10.0", () {
    migration0100 = true;
  });
}

whenRunsTwoApplicationUpdatesCalls() async {
  await VersionMigration.applicationUpdate(() {});
  await VersionMigration.applicationUpdate(() {
    applicationUpdate = true;
  });
}

whenResetVersionMigration() {
  VersionMigration.reset();
  reset();
}

expectMigrationIsDone() {
  expect(migration090, true);
  expect(migration100, true);
}

expectMigrationIsNotDone() {
  expect(migration090, false);
  expect(migration100, false);
}

expectOnlyOrderedMigrationsAreDone() {
  expect(migration090, true);
  expect(migration010, false);
  expect(migration0100, true);
}

expectOnlyRunsFirstApplicationUpdate() {
  expect(applicationUpdate, false);
}