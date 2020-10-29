import 'project_base.dart';

class Dependency {
  final Package rootPackage;

  Dependency({
    this.rootPackage,
  });

  factory Dependency.fromYaml({
    Package rootPackage,
    object,
  }) {
    if (object is MapEntry) {
      return Dependency.fromMapEntry(
        rootPackage: rootPackage,
        entry: object,
      );
    }

    return null;
  }

  factory Dependency.fromMapEntry({
    Package rootPackage,
    MapEntry entry,
  }) {
    final dep = Dependency(
      rootPackage: rootPackage,
    )
      .._name = entry.key
      .._type = getType(entry.value);

    return dep;
  }

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

  String get name {
    return _name;
  }

  DependencyType _type;

  DependencyType get type {
    return _type;
  }

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

  String get version => package.version;
}

enum DependencyType {
  pub,
  path,
  git,
  sdk,
}
