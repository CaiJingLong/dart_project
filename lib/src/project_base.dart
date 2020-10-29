import 'dart:io';

import 'package:pub_semver/pub_semver.dart';
import 'package:yaml/yaml.dart';
import 'package:path/path.dart' as path_library;

import 'dependency.dart';
import 'flutter/flutter_info.dart';
import 'packages_file_info.dart';

/// The Package
class Package {
  Package(this.packageDir, [Package rootPackage])
      : assert(packageDir.existsSync()),
        _rootPackage = rootPackage,
        yamlFile = packageDir.child('pubspec.yaml');

  factory Package.fromPath(String path, [Package rootPackage]) {
    return Package(Directory(path), rootPackage);
  }

  /// The root directory of the package.
  final Directory packageDir;

  /// The pubspec.yaml file of the package.
  final File yamlFile;

  Package _rootPackage;

  /// The root package of the package.
  ///
  /// Your main method.
  Package get rootPackage {
    _rootPackage ??= this;
    return _rootPackage;
  }

  YamlMap _yamlMap;

  /// Convert the yaml file to [YamlMap].
  YamlMap get yamlMap {
    _yamlMap ??= loadYaml(yamlFile.readAsStringSync());
    return _yamlMap;
  }

  /// The name of the yaml file.
  String get name => yamlMap['name'];

  /// The description of the yaml file.
  String get description => yamlMap['description'];

  /// The version of the yaml file.
  String get version => yamlMap['version'];

  /// The sem version of the [version].
  Version get semVersion => Version.parse(version);

  /// The home page of the yaml file.
  String get homepage => yamlMap['homepage'];

  /// The value of the yaml map.
  T configValue<T>(String key) {
    return yamlMap[key];
  }

  /// The [yamlMap] contains the [key].
  bool containsKey(String key) {
    return yamlMap.containsKey(key);
  }

  /// Your dependencies of the yaml file.
  List<Dependency> get dependencies {
    return _dependencies('dependencies');
  }

  /// Your dev_dependencies of the yaml file.
  List<Dependency> get devDependencies {
    return _dependencies('dev_dependencies');
  }

  List<Dependency> _dependencies(String key) {
    final dependencies = <Dependency>[];

    final YamlMap dependencyMap = yamlMap[key];

    for (final dependency in dependencyMap?.entries ?? []) {
      final dep = Dependency.fromYaml(
        rootPackage: rootPackage,
        object: dependency,
      );
      dependencies.add(dep);
    }

    return dependencies;
  }

  PackageFileInfo _packageFileInfo;

  /// The .package file info, you must run `pub get` or `flutter pub get` to make it.
  PackageFileInfo get packageFileInfo {
    _packageFileInfo ??=
        PackageFileInfo(File('${rootPackage.packageDir.path}/.packages'));

    return _packageFileInfo;
  }

  /// Whether it is a flutter project.
  bool get isFlutter => containsKey('flutter');

  /// The flutter info
  FlutterInfo get flutterInfo {
    assert(isFlutter);
    return FlutterInfo(
      map: yamlMap['flutter'],
      package: this,
    );
  }

  File childFile(String key) {
    return packageDir.child(key);
  }
}

extension DirExt on Directory {
  File child(String name) {
    return File('$path/$name');
  }

  Directory childDir(String name) {
    return Directory('$path/$name');
  }
}

extension FileSystemEntityExt on FileSystemEntity {
  String get name {
    final sep = path_library.separator;
    var p = absolute.path;
    if (p.endsWith(sep)) {
      return p
          .split(path_library.separator)
          .lastWhere((element) => element.isNotEmpty);
    } else {
      return p.split(path_library.separator).last;
    }
  }

  bool identicalOther(FileSystemEntity other) {
    return FileSystemEntity.identicalSync(absolute.path, other.absolute.path);
  }
}
