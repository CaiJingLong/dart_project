import 'package:project/project.dart';

void main() {
  final pkg = Package.fromPath('example/flutter_project');
  final assets = <FlutterAsset>[];

  addAssetsToList(assets, pkg);

  print(assets.map((e) {
    return '${e.assetKey}:\n  file: ${e.file.absolute.path}';
  }).join('\n'));
}

/// ![](/Users/jinglongcai/code/dart/self/project/example/flutter_project/assets/images/download.png)
Set<String> names = {};

void addAssetsToList(List<FlutterAsset> keys, Package pkg) {
  final name = pkg.name;
  if (names.contains(name)) {
    return;
  }
  names.add(name);

  if (pkg.isFlutter) {
    final flutterInfo = pkg.flutterInfo;
    keys.addAll(flutterInfo.assets);
  }

  for (final dep in pkg.dependencies) {
    final depPkg = dep.package;
    if (depPkg != null) {
      addAssetsToList(keys, depPkg);
    }
  }
}
