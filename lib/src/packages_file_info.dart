import 'dart:io';
import 'project_base.dart';
import 'package:path/path.dart' as path_library;

/// The .packages file info the application project.
class PackageFileInfo {
  /// You need create the instance of the `File`.
  PackageFileInfo(this.package, this.file) : assert(file.existsSync());

  final Package package;

  /// The file of the .packages file.
  final File file;

  /// Package information list.
  List<PackageInfo> get packageInfos {
    final packageInfos = <PackageInfo>[];

    final lines = file.readAsLinesSync();

    for (final line in lines) {
      final packageInfo = PackageInfo.fromLine(package, line);

      if (packageInfo == null) {
        continue;
      }
      packageInfos.add(packageInfo);
    }

    return packageInfos;
  }

  /// The map key is [Package.name];
  Map<String, PackageInfo> getPackageMap() {
    final map = <String, PackageInfo>{};
    for (final pkg in packageInfos) {
      map[pkg.name] = pkg;
    }

    return map;
  }

  /// Use the operator, which is equivalent to `getPackageMap()[key]`;
  PackageInfo operator [](String key) {
    return getPackageMap()[key];
  }

  /// Use the operator,
  ///
  /// which is equivalent to `getPackageMap().containsKey(key)`;
  bool containsPackage(String key) {
    return getPackageMap().containsKey(key);
  }
}

/// The package info
class PackageInfo {
  PackageInfo(this.package, this.name, this.uriString);

  /// Create the instance use the line string of the .package file.
  factory PackageInfo.fromLine(Package package, String line) {
    if (line.startsWith('#')) {
      return null;
    }

    final splitter = line.indexOf(':');

    final key = line.substring(0, splitter);
    final value = line.substring(splitter + 1);

    return PackageInfo(package, key, value);
  }

  final String name;
  final String uriString;
  final Package package;

  Uri get uri => Uri.parse(uriString);

  Directory get packageDirectory {
    final path = Directory.fromUri(uri).path;

    final target = path_library.join(
      package.rootPackage.packageDir.path,
      path,
    );

    return Directory(target).parent;
  }
}
