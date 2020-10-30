import 'dart:collection';

import 'dart:io';
import '../project_base.dart';

class FlutterAsset {
  FlutterAsset(this.key, this._assets, this.package)
      : file = package.childFile(key);

  static List<FlutterAsset> fromDirectory(
    String dirAsset,
    List<FlutterAsset> _assets,
    Package package,
  ) {
    final dir = package.packageDir.childDir(dirAsset);
    return dir.listSync().whereType<File>().map((e) {
      final name = e.name;
      final file = dir.child(name);

      final key = file.relativeOther(package.packageDir);

      return FlutterAsset(key, _assets, package);
    }).toList();
  }

  final String key;

  final List<FlutterAsset> _assets;

  final Package package;

  final File file;

  String get assetKey {
    if (package.isRootPackage) {
      return key;
    } else {
      return 'lib/${package.name}/$key';
    }
  }

  FlutterAssetVariants _variants;

  FlutterAssetVariants getVariants() {
    if (_variants != null) return _variants;
    _variants ??= FlutterAssetVariants();

    // Add this to the variants.
    _variants.add(FlutterAssetVariant('default', this));

    // find it from _assets;
    for (var asset in _assets) {
      if (identical(asset, this)) {
        continue;
      }

      // fix it.
      final otherFile = asset.file;
      if (otherFile.name == file.name &&
          otherFile.parent.parent.identicalOther(file.parent)) {
        final key = otherFile.parent.name;
        _variants.add(FlutterAssetVariant(key, asset));
      }
    }

    return _variants;
  }
}

class FlutterAssetVariants extends MapBase<String, FlutterAssetVariant> {
  final assets = <String, FlutterAssetVariant>{};

  @override
  FlutterAssetVariant operator [](Object key) {
    return assets[key];
  }

  @override
  void operator []=(String key, FlutterAssetVariant value) {
    assets[key] = value;
  }

  @override
  void clear() {
    assets.clear();
  }

  @override
  Iterable<String> get keys => assets.keys;

  @override
  FlutterAssetVariant remove(Object key) {
    return assets.remove(key);
  }

  void add(FlutterAssetVariant variant) {
    assert(variant != null);
    this[variant.key] = variant;
  }
}

class FlutterAssetVariant {
  final String key;
  final FlutterAsset asset;

  FlutterAssetVariant(this.key, this.asset);
}
