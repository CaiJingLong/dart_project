import 'dart:collection';
import 'dart:io';

import 'package:yaml/yaml.dart';
import 'package:meta/meta.dart';
import 'package:collection/collection.dart';
import 'project_base.dart';
import 'source_utils.dart';

/// Some info for Flutter project.
class FlutterInfo {
  final YamlMap _map;

  final Directory rootDir;

  FlutterInfo({
    @required YamlMap map,
    @required this.rootDir,
  }) : _map = map;

  bool get useMaterialDesign => _map['uses-material-design'] == true;

  bool get isApplication {
    final mainFile = rootDir.child('lib/main.dart');
    return SourceUtils.containsMethod(mainFile, 'main');
  }

  bool get haveAndroid {
    return _haveDir('android');
  }

  bool get haveIOS {
    return _haveDir('ios');
  }

  bool get haveMacOS {
    return _haveDir('macos');
  }

  bool get haveWeb {
    return _haveDir('web');
  }

  bool get haveLinux => _haveDir('linux');

  bool get haveWindows => _haveDir('windows');

  bool _haveDir(String key) {
    return rootDir.childDir(key).existsSync();
  }

  List<FlutterAsset> _assets;

  List<FlutterAsset> get assets {
    if (_assets != null) {
      return _assets;
    }

    final assets = <FlutterAsset>[];
    _assets ??= assets;

    final list = _map['assets'];
    if (list == null) {
      return assets;
    }

    for (final String asset in list) {
      if (asset.endsWith('/')) {
        final result = FlutterAsset.fromDirectory(
          rootDir.childDir(asset),
          assets,
        );
        assets.addAll(result);
      } else {
        assets.add(
          FlutterAsset(
            rootDir.child(asset),
            assets,
          ),
        );
      }
    }

    return assets;
  }
}

class FlutterAsset {
  final File file;

  final List<FlutterAsset> _assets;

  FlutterAsset(this.file, this._assets);

  static List<FlutterAsset> fromDirectory(
      Directory directory, List<FlutterAsset> _assets) {
    return directory
        .listSync()
        .whereType<File>()
        .map((e) => FlutterAsset(e, _assets));
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

      final otherFile = asset.file;
      if (otherFile.name == file.name &&
          otherFile.parent.parent == file.parent) {
        final key = otherFile.parent.name;
        _variants.add(FlutterAssetVariant(key, asset));
      }
    }

    return _variants;
  }

  // bool
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
