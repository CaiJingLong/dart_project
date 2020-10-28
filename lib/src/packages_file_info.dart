import 'dart:io';

/// The .packages file info the application project.
class PackageFileInfo {
  final File file;

  PackageFileInfo(this.file) : assert(file.existsSync());

  List<PackageInfo> get packageInfos {
    final packageInfos = <PackageInfo>[];

    final lines = file.readAsLinesSync();

    for (final line in lines) {
      if (line.startsWith('#')) {
        continue;
      }

      final splitter = line.indexOf(':');

      final key = line.substring(0, splitter);
      final value = line.substring(splitter + 1);

      packageInfos.add(PackageInfo(key, value));
    }

    return packageInfos;
  }

  Map<String, PackageInfo> getPackageMap() {
    final map = <String, PackageInfo>{};
    for (final pkg in packageInfos) {
      map[pkg.name] = pkg;
    }

    return map;
  }

  PackageInfo operator [](String key) {
    return getPackageMap()[key];
  }

  bool containsPackage(String key) {
    return getPackageMap().containsKey(key);
  }
}

/// The package info
class PackageInfo {
  PackageInfo(this.name, this.uriString);

  final String name;
  final String uriString;

  Uri get uri => Uri.parse(uriString);

  Directory get packageDirectory => Directory.fromUri(uri).parent;
}
