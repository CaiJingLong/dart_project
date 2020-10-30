import 'dart:io';

import 'package:pub_semver/pub_semver.dart';
import 'package:yaml/yaml.dart';
import 'package:path/path.dart' as path_library;

import 'dependency.dart';
import 'flutter/flutter_info.dart';
import 'packages_file_info.dart';

/// [Package], usually the entry class.
///
/// Example:
///
/// ```dart
/// final package = Package.fromPath('flutter_project');
///
/// print(package.name);
/// print(package.version);
/// ```
class Package {
  /// Use [packageDir] to create a [Package].
  ///
  /// Users generally do not need to consider [rootPackage].
  Package(this.packageDir, [Package rootPackage])
      : assert(packageDir.existsSync()),
        _rootPackage = rootPackage,
        yamlFile = packageDir.child('pubspec.yaml');

  /// Use [path] to create a [Package].
  ///
  /// Users generally do not need to consider [rootPackage].
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

  /// Is this package a root package.
  bool get isRootPackage => identical(this, rootPackage);

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
        PackageFileInfo(this, File('${rootPackage.packageDir.path}/.packages'));

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

  /// Get the [File] in the package by [name].
  File childFile(String name) {
    return packageDir.child(name);
  }

  /// Get [Dependency] by [name].
  ///
  /// No recursion, only find dependency in yaml.
  Dependency getDependency(String name) {
    return dependencies.firstWhere(
      (element) => element.name == name,
      orElse: () => null,
    );
  }

  /// Get dart files in `lib/` directory in package.
  List<File> get dartSources {
    final libFiles = files('lib');
    return libFiles
        .where(
          (element) => element.name.endsWith('.dart'),
        )
        .toList();
  }

  /// Get files from [path] in package.
  List<File> files(String path) {
    final dir = packageDir.childDir(path);
    return dir.listSync().whereType<File>().toList();
  }
}

/// Some [Directory] extension.
extension DirExt on Directory {
  /// Get [File] by [name].
  File child(String name) {
    var p = path;
    if (p.endsWith('/')) {
      p = p.substring(0, p.length - 1);
    }
    return File('$path/$name');
  }

  /// Get [Directory] by [name].
  Directory childDir(String name) {
    var p = path;
    if (p.endsWith('/')) {
      p = p.substring(0, p.length - 1);
    }
    return Directory('$p/$name');
  }
}

/// Some FileSystemEntity extension.
extension FileSystemEntityExt on FileSystemEntity {
  /// The name of the file system entity.
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

  /// Use [FileSystemEntity.identicalSync] to compare other [FileSystemEntity].
  bool identicalOther(FileSystemEntity other) {
    return FileSystemEntity.identicalSync(absolute.path, other.absolute.path);
  }

  /// Use [path_library.relative] to get
  /// the relative path with other [FileSystemEntity].
  String relativeOther(FileSystemEntity other) {
    return path_library.relative(absolute.path, from: other.absolute.path);
  }
}
