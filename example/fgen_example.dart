import 'package:project/project.dart';

/// The dart file will output:
/// ```log
/// assets/images/download.png:
///   file: /Users/jinglongcai/code/dart/self/project/example/flutter_project/assets/images/download.png
/// assets/images/2.0x/download.png:
///   file: /Users/jinglongcai/code/dart/self/project/example/flutter_project/assets/images/2.0x/download.png
/// packages/flutter_plugin/assets/wechat_pay.png:
///   file: /Users/jinglongcai/code/dart/self/project/example/flutter_project/../flutter_plugin/assets/wechat_pay.png
/// ```
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
