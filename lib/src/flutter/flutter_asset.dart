import 'dart:collection';

import 'dart:io';
import '../project_base.dart';

/// Describes of the flutter asset.
class FlutterAsset {
  /// The user does not need to call this method.
  FlutterAsset(this.key, this._assets, this.package)
      : file = package.childFile(key);

  /// Use this method to create a list
  /// when the assert defined in pubspec is a directory.
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

  /// The key of asset.
  final String key;

  /// Pass in from the previous layer for the list
  /// containing all the assets defined in the current package.
  final List<FlutterAsset> _assets;

  /// The package of the asset.
  final Package package;

  /// The asset file.
  final File file;

  /// This key can be used in the flutter project.
  /// If the [package] is not root package,
  /// it will contain `lib/package/` prefix.
  String get assetKey {
    if (package.isRootPackage) {
      return key;
    } else {
      return 'packages/${package.name}/$key';
    }
  }

  FlutterAssetVariants _variants;

  /// Find the variants of the asset.
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

/// Describes a collection of variants.
///
/// It is a [Map].
class FlutterAssetVariants extends MapBase<String, FlutterAssetVariant> {
  /// A [Map] that contains all flutter asset variants.
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

  /// Use simple method to add the variant to [assets].
  void add(FlutterAssetVariant variant) {
    assert(variant != null);
    this[variant.key] = variant;
  }
}

/// Describes flutter asset variant.
class FlutterAssetVariant {
  /// Using [key] and [asset] to create [FlutterAssetVariant] instance.
  FlutterAssetVariant(this.key, this.asset);

  /// When the variant is the main variant,
  /// the [FlutterAssetVariant.key] will be 'default'.
  static const defKey = 'default';

  /// The key of the variant.
  final String key;

  /// The asset of the variant.
  final FlutterAsset asset;
}
