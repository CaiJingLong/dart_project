import 'dart:io';

import 'package:yaml/yaml.dart';

import 'dependency.dart';
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

  /// The root directory of the project.
  final Directory packageDir;

  /// The pubspec.yaml file of the project.
  final File yamlFile;

  Package _rootPackage;

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

  /// The name of the project.
  String get name => yamlMap['name'];
  String get description => yamlMap['description'];
  String get version => yamlMap['version'];
  String get homepage => yamlMap['homepage'];

  List<Dependency> get dependencies {
    return _dependencies('dependencies');
  }

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

  PackageFileInfo get packageFileInfo {
    _packageFileInfo ??=
        PackageFileInfo(File('${rootPackage.packageDir.path}/.packages'));

    return _packageFileInfo;
  }
}

extension _DirExt on Directory {
  File child(String name) {
    return File('$path/$name');
  }
}
