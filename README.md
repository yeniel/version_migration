VersionMigration
===========

[![Codemagic build status](https://api.codemagic.io/apps/5e29e24fcc644b0019cec109/5e29e24fcc644b0019cec108/status_badge.svg)](https://codemagic.io/apps/5e29e24fcc644b0019cec109/5e29e24fcc644b0019cec108/latest_build)

This a translation of the library MTMigration (https://github.com/mysterioustrousers/MTMigration) to a Dart Package.

Manages functions of code that need to run once on version updates in Flutter apps. This could be anything from data
normalization routines, "What's New In This Version" screens, or bug fixes.

## Installation

Add in pubspec:

```
version_migration: ^1.0.2
```

## Usage

If you need a function that runs every time your application version changes, pass that function to
the `applicationUpdate` method.

```dart
VersionMigration.applicationUpdate(() {
    metrics.resetStats();
});
```

If the function is specific to a version, use `migrateToVersion` and VersionMigration will
ensure that the function is only ever run once for that version.

```dart
VesionMigration.migrateToVersion("1.1", () {
    newness.presentNewness();
});
```

Because VersionMigration inspects your actual version number and keeps track of the last migration,
it will migrate all un-migrated functions inbetween. For example, let's say you had the following migrations:

```dart
VersionMigration.migrateToVersion("0.9", () {
    // Some 0.9 stuff
});

VersionMigration.migrateToVersion("1.0", () {
    // Some 1.0 stuff
});
```

If a user was at version `0.8`, skipped `0.9`, and upgraded to `1.0`, then both the `0.9` *and* `1.0` functions would run.

For debugging/testing purposes, you can call `reset` to clear out the last migration VersionMigration remembered, causing all
migrations to run from the beginning:

```dart
VersionMigration.reset();
```

## Notes

VersionMigration assumes version numbers are incremented in a logical way, i.e. `1.0.1` -> `1.0.2`, `1.1` -> `1.2`, etc.

Version numbers that are past the version specified in your app will not be run. For example, if your pubspec file
specifies `1.2` as the app's version number, and you attempt to migrate to `1.3`, the migration will not run.

## Contributing

This library does not handle some more intricate migration situations, if you come across intricate use cases from your own
app, please add it and submit a pull request. Be sure to add test cases.
