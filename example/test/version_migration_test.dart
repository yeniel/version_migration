import 'package:flutter_test/flutter_test.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:version_migration/version_migration.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
  });

  tearDown(() async {
    await VersionMigration.reset();
    resetMigrationExecutedFlags();
  });

  group("GIVEN app with version $currentVersion", () {
    group("WHEN reset migrations", () {
      test('THEN if run current version migration again, should be executed',
          () async {
        givenApp(version: currentVersion);

        await whenResetMigrationsAndExecuteMigrationAgain();

        thenExpectMigrationIsExecuted();
      });
    });

    group('WHEN migrate to version $currentVersion', () {
      test('THEN migration is executed', () async {
        givenApp(version: currentVersion);

        await whenExecuteMigration(currentVersion);

        thenExpectMigrationIsExecuted();
      });
    });

    group("WHEN execute same migration $currentVersion twice", () {
      test("THEN migration is executed once", () async {
        givenApp(version: currentVersion);

        await whenExecuteSameMigrationTwice(currentVersion);

        thenExpectMigrationIsNotExecuted();
      });
    });

    group("WHEN execute migrations in wrong order", () {
      test("THEN only ordered migrations are executed", () async {
        givenApp(version: currentVersion);

        await whenExecuteMigrationsInWrongOrder();

        thenExpectOnlyOrderedMigrationsAreExecuted();
      });
    });

    group("WHEN execute migration for any version", () {
      test("THEN the migration is executed", () async {
        givenApp(version: currentVersion);

        await whenExecuteMigrationForAnyVersion();

        thenExpectMigrationForAnyVersionIsExecuted();
      });
    });

    group("WHEN execute migration for any version twice", () {
      test("THEN the migration is executed once", () async {
        givenApp(version: currentVersion);

        await whenExecuteMigrationForAnyVersionTwice();

        thenExpectMigrationForAnyVersionIsNotExecuted();
      });
    });
  });
}

String firstVersion = "0.5.0";
String previousVersion = "1.0.0";
String currentVersion = "2.0.0";
bool previousMigrationExecuted = false;
bool currentVersionMigrationExecuted = false;
bool firstMigrationExecuted = false;
bool applicationUpdate = false;

// GIVEN

void givenApp({String version = "2.0.0", String build = "0"}) {
  PackageInfo.setMockInitialValues(
    appName: 'VersionMigration',
    packageName: 'VersionMigration',
    version: version,
    buildNumber: build,
    buildSignature: "",
  );
}

// WHEN

Future<void> whenResetMigrationsAndExecuteMigrationAgain() async {
  await whenExecuteMigration(currentVersion);
  await whenResetVersionMigration();
  await whenExecuteMigration(currentVersion);
}

Future<void> whenExecuteMigration(String version) async {
  await VersionMigration.migrateToVersion(version, () {
    setVersionMigrationFlag(version);
  });
}

Future<void> whenExecuteSameMigrationTwice(String version) async {
  await whenExecuteMigration(version);
  resetMigrationExecutedFlags();
  await whenExecuteMigration(version);
}

Future<void> whenExecuteMigrationsInWrongOrder() async {
  await VersionMigration.migrateToVersion(previousVersion, () {
    setVersionMigrationFlag(previousVersion);
  });

  await VersionMigration.migrateToVersion(firstVersion, () {
    setVersionMigrationFlag(firstVersion);
  });

  await VersionMigration.migrateToVersion(currentVersion, () {
    setVersionMigrationFlag(currentVersion);
  });
}

Future<void> whenExecuteMigrationForAnyVersion() async {
  await VersionMigration.applicationUpdate(() {
    applicationUpdate = true;
  });
}

Future<void> whenExecuteMigrationForAnyVersionTwice() async {
  await VersionMigration.applicationUpdate(() {
    applicationUpdate = true;
  });

  applicationUpdate = false;

  await VersionMigration.applicationUpdate(() {
    applicationUpdate = true;
  });
}

Future<void> whenResetVersionMigration() async {
  await VersionMigration.reset();
  resetMigrationExecutedFlags();
}

void resetMigrationExecutedFlags() {
  previousMigrationExecuted = false;
  currentVersionMigrationExecuted = false;
  firstMigrationExecuted = false;
  applicationUpdate = false;
}

void setVersionMigrationFlag(String version) {
  if (version == firstVersion) {
    firstMigrationExecuted = true;
  }

  if (version == previousVersion) {
    previousMigrationExecuted = true;
  }

  if (version == currentVersion) {
    currentVersionMigrationExecuted = true;
  }
}

//THEN

thenExpectMigrationIsExecuted() {
  expect(currentVersionMigrationExecuted, isTrue);
}

void thenExpectMigrationIsNotExecuted() {
  expect(currentVersionMigrationExecuted, isFalse);
}

void thenExpectOnlyOrderedMigrationsAreExecuted() {
  expect(previousMigrationExecuted, isTrue);
  expect(firstMigrationExecuted, isFalse);
  expect(currentVersionMigrationExecuted, isTrue);
}

void thenExpectMigrationForAnyVersionIsExecuted() {
  expect(applicationUpdate, isTrue);
}

void thenExpectMigrationForAnyVersionIsNotExecuted() {
  expect(applicationUpdate, isFalse);
}
