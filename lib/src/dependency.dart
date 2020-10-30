import 'package:meta/meta.dart';

import 'project_base.dart';

/// Describe dependency.
class Dependency {
  /// Use [rootPackage] to create [Dependency] object.
  Dependency({
    this.rootPackage,
  });

  /// The result may be null.
  ///
  /// Must rootPackage.
  ///
  /// The [object] is the yaml.
  factory Dependency.fromYaml({
    @required Package rootPackage,
    @required object,
  }) {
    if (object is MapEntry) {
      return Dependency.fromMapEntry(
        rootPackage: rootPackage,
        entry: object,
      );
    }

    return null;
  }

  /// Using the dependency node to create [Dependency] object.
  factory Dependency.fromMapEntry({
    @required Package rootPackage,
    @required MapEntry entry,
  }) {
    final dep = Dependency(
      rootPackage: rootPackage,
    )
      .._name = entry.key
      .._type = getType(entry.value);

    return dep;
  }

  /// The root package.
  final Package rootPackage;

  /// Convert type value of yaml to the [DependencyType].
  ///
  /// If it is null, there is a problem. Please submit an issue.
  static DependencyType getType(value) {
    if (value is String) {
      return DependencyType.pub;
    } else if (value is Map) {
      if (value.containsKey('path')) {
        return DependencyType.path;
      } else if (value.containsKey('git')) {
        return DependencyType.git;
      } else if (value.containsKey('sdk')) {
        return DependencyType.sdk;
      }
    }

    return null;
  }

  String _name;

  /// The name of the dependency.
  String get name {
    return _name;
  }

  DependencyType _type;

  /// The type of the dependency.
  DependencyType get type {
    return _type;
  }

  /// The package of the dependency.
  ///
  /// It be found with name by the `.package` file of root package.
  Package get package {
    try {
      final packageInfo = rootPackage.packageFileInfo[name];
      if (packageInfo == null) {
        return null;
      }
      final packageDirectory = packageInfo.packageDirectory;
      return Package(packageDirectory, rootPackage);
    } on Exception {
      return null;
    }
  }

  /// The version of the dependency.
  String get version => package.version;
}

/// Type of the dependency.
enum DependencyType {
  /// The package come from [pub](https://pub.dev).
  pub,

  /// Local packages.
  path,

  /// The package is from git.
  git,

  /// The package come from sdk(flutter or dart).
  sdk,
}
