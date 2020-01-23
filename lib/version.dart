import 'dart:math';

import 'package:flutter/foundation.dart';

/// Model to represent a version
class Version implements Comparable<Version> {
  final String version;

  /// The version is passed as string in the format Major.Minor.Micro (Eg. 1.0.0)
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
