import 'dart:io';

import 'package:yaml/yaml.dart';
import 'package:meta/meta.dart';

import 'flutter_asset.dart';
import '../project_base.dart';
import '../source_utils.dart';
import 'flutter_font.dart';

/// Some info for Flutter project.
class FlutterInfo {
  FlutterInfo({
    @required YamlMap map,
    @required this.package,
  }) : _map = map;

  /// The flutter node of pubspec.yaml.
  final YamlMap _map;

  /// This information belongs to the package.
  final Package package;

  /// The package root directory.
  Directory get rootDir => package.packageDir;

  /// The `uses-material-design` of the flutter node.
  bool get useMaterialDesign => _map['uses-material-design'] == true;

  /// By checking whether there is the `lib/main.dart` file
  /// and `main` method agreed by the Flutter project,
  /// to determine whether it is a Flutter project.
  bool get isApplication {
    final mainFile = rootDir.child('lib/main.dart');
    if (!mainFile.existsSync()) {
      return false;
    }
    return SourceUtils.containsMethod(mainFile, 'main');
  }

  /// Check whether the flutter in the yaml file
  /// has a plugin child node to judge.
  bool get isPlugin {
    return _map['plugin'] != null;
  }

  /// Whether to include the android folder.
  bool get haveAndroid {
    return _haveDir('android');
  }

  /// Whether to include the ios folder.
  bool get haveIOS {
    return _haveDir('ios');
  }

  /// Whether to include the macos folder.
  bool get haveMacOS {
    return _haveDir('macos');
  }

  /// Whether to include the web folder.
  bool get haveWeb {
    return _haveDir('web');
  }

  /// Whether to include the linux folder.
  bool get haveLinux => _haveDir('linux');

  /// Whether to include the windows folder.
  bool get haveWindows => _haveDir('windows');

  bool _haveDir(String key) {
    return rootDir.childDir(key).existsSync();
  }

  List<FlutterAsset> _assets;

  /// The asset node of the flutter node.
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
          asset,
          assets,
          package,
        );
        assets.addAll(result);
      } else {
        assets.add(
          FlutterAsset(
            asset,
            assets,
            package,
          ),
        );
      }
    }

    return assets;
  }

  bool containsFonts() {
    return _map.containsKey('fonts');
  }

  FlutterFonts get fonts {
    return FlutterFonts(
      list: _map['fonts'],
      package: package,
    );
  }

  /// Whether the flutter package contains assets.
  bool get containsAsset => assets.isNotEmpty;
}
