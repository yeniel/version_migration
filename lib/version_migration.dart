library version_migration;

import 'package:package_info/package_info.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:version_migration/version.dart';

class VersionMigration {
  static String _lastMigratedVersionKey = "Migrator.lastMigratedVersionKey";
  static String _lastUpdatedAppVersionKey = "Migrator.lastUpdatedAppVersionKey";

  static Future<void> migrateToVersion(String version, Function migrationFunction) async {
    Version newVersion = Version(version: version);

    if (await _newVersionIsGreaterThanLastMigratedVersion(newVersion) &&
        await _newVersionIsNotGreatherThanAppVersion(newVersion)) {
      migrationFunction();
      _setLastMigratedVersion(version.toString());
    }
  }

  static Future<void> applicationUpdate(Function updateFunction) async {
    Version lastUpdatedAppVersion = await _getLastUpdatedAppVersion();
    PackageInfo packageInfo = await PackageInfo.fromPlatform();

    if (lastUpdatedAppVersion.toString() != packageInfo.version) {
      updateFunction();
      _setLastUpdatedAppVersion(packageInfo.version);
    }
  }

  static reset() {
    _setLastMigratedVersion(null);
    _setLastUpdatedAppVersion(null);
  }

  static Future<Version> _getLastMigratedVersion() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    return Version(version: prefs.getString(_lastMigratedVersionKey) ?? "0.0.0");
  }

  static Future<bool> _setLastMigratedVersion(String value) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    return prefs.setString(_lastMigratedVersionKey, value);
  }

  static Future<Version> _getLastUpdatedAppVersion() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    return Version(version: prefs.getString(_lastUpdatedAppVersionKey) ?? "0.0.0");
  }

  static Future<bool> _setLastUpdatedAppVersion(String value) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    return prefs.setString(_lastUpdatedAppVersionKey, value);
  }

  static Future<bool> _newVersionIsGreaterThanLastMigratedVersion(Version newVersion) async {
    Version lastMigratedVersion = await _getLastMigratedVersion();

    return newVersion.compareTo(lastMigratedVersion) == 1;
  }

  static Future<bool> _newVersionIsNotGreatherThanAppVersion(Version newVersion) async {
    PackageInfo packageInfo = await PackageInfo.fromPlatform();
    Version appVersion = Version(version: packageInfo.version);

    return newVersion.compareTo(appVersion) < 1;
  }
}
