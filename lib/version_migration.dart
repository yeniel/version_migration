library version_migration;

import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:package_info/package_info.dart';
import 'package:shared_preferences/shared_preferences.dart';

class VersionMigration {

  static String lastMigratedVersionKey = "Migrator.lastMigratedVersionKey";
  static String lastUpdatedAppVersionKey = "Migrator.lastUpdatedAppVersionKey";

  static Future<void> migrateToVersion(String version, Function migrationFunction) async {
    Version newVersion = Version(version: version);
    PackageInfo packageInfo = await PackageInfo.fromPlatform();
    Version appVersion = Version(version: packageInfo.version);
    Version lastMigratedVersion = await getLastMigratedVersion();

    if (newVersion.compareTo(lastMigratedVersion) == 1 && newVersion.compareTo(appVersion) == 1) {
      migrationFunction();
      setLastMigratedVersion(version.toString());
    }
  }

  static Future<void> applicationUpdate(Function updateFunction) async {
    Version lastUpdatedAppVersion = await getLastUpdatedAppVersion();
    PackageInfo packageInfo = await PackageInfo.fromPlatform();

    if (lastUpdatedAppVersion.toString() != packageInfo.version) {
      updateFunction();
      setLastUpdatedAppVersion(packageInfo.version);
    }
  }

  static reset() {
    setLastMigratedVersion(null);
    setLastUpdatedAppVersion(null);
  }

  static Future<Version> getLastMigratedVersion() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    return Version(version: prefs.getString(lastMigratedVersionKey) ?? "0.0.0");
  }

  static Future<bool> setLastMigratedVersion(String value) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    return prefs.setString(lastMigratedVersionKey, value);
  }

  static Future<Version> getLastUpdatedAppVersion() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    return Version(version: prefs.getString(lastUpdatedAppVersionKey) ?? "0.0.0");
  }

  static Future<bool> setLastUpdatedAppVersion(String value) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    return prefs.setString(lastUpdatedAppVersionKey, value);
  }
}

class Version implements Comparable<Version> {
  final String version;

  Version({@required this.version}) {
    if (version == null) {
      throw FormatException();
    } else {
      RegExp versionRegExp = new RegExp(r"[0-9]+(\\.[0-9]+)*");

      if (!versionRegExp.hasMatch(version)) {
        throw FormatException();
      }
    }
  }

  @override
  int compareTo(Version other) {
    if (other == null) {
      return 1;
    } else {
      List<int> versionParts = version.split(".").map((part) => int.parse(part)).toList();
      List<int> otherParts = other.version.split(".").map((part) => int.parse(part)).toList();

      int numberOfParts = max(versionParts.length, otherParts.length);

      for (var index = 0; index < numberOfParts; index++) {
        int versionPart = index < versionParts.length ? versionParts[index] : 0;
        int otherPart = index < otherParts.length ? otherParts[index] : 0;

        if (versionPart < otherPart) {
          return -1;
        }

        if (versionPart > otherPart) {
          return 1;
        }
      }

      return 0;
    }
  }

  @override
  String toString() {
    return version;
  }

}
