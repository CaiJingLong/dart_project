import 'package:meta/meta.dart';
import 'package:yaml/yaml.dart';

import '../project_base.dart';

/// Describes all the flutter fonts in a package.
class FlutterFonts {
  /// Create instance with [package] and [list].
  FlutterFonts({
    @required this.package,
    @required YamlList list,
  }) : list = list;

  /// The package of the font.
  final Package package;

  /// The flutter font of yaml node.
  final YamlList list;

  /// Get the list of [FlutterFont].
  List<FlutterFont> get fonts {
    final result = <FlutterFont>[];

    if (list == null) {
      return result;
    }

    for (final node in list) {
      final String family = node['family'];

      final font = FlutterFont(familyName: family, package: package);

      final YamlList assets = node['fonts'];

      for (final asset in assets) {
        final flutterFontAsset = FlutterFontAsset.fromYamlNode(package, asset);
        font.add(flutterFontAsset);
      }

      result.add(font);
    }

    return result;
  }
}

/// Describes an font of the Flutter.
class FlutterFont {
  /// Create instance with [package] and [familyName].
  FlutterFont({
    @required this.package,
    @required this.familyName,
  });

  /// The package of the font.
  final Package package;

  /// The family name of the font.
  final String familyName;

  /// The assets of the font.
  final List<FlutterFontAsset> assets = <FlutterFontAsset>[];

  /// Add the [flutterFontAsset] to the [assets] list.
  void add(FlutterFontAsset flutterFontAsset) {
    assets.add(flutterFontAsset);
  }
}

/// An asset used to describe a font.
class FlutterFontAsset {
  /// Create an instance of [FlutterFontAsset].
  FlutterFontAsset({
    @required this.key,
    @required this.package,
    this.style = FontStyle.normal,
    this.weight = 400,
  });

  /// Create [FlutterFontAsset] instance from yaml node data.
  static FlutterFontAsset fromYamlNode(Package package, assetNode) {
    if (assetNode == null) {
      return null;
    }

    if (assetNode is String) {
      return FlutterFontAsset(
        package: package,
        key: assetNode,
      );
    }

    if (assetNode is YamlMap) {
      final key = assetNode['asset'];
      final style = assetNode['style'];
      final weightValue = assetNode['weight'].toString();

      var fontStyle = FontStyle.normal;
      if (style == 'italic') {
        fontStyle = FontStyle.italic;
      }

      final weight = int.tryParse(weightValue) ?? 400;

      return FlutterFontAsset(
        package: package,
        key: key,
        weight: weight,
        style: fontStyle,
      );
    }

    return null;
  }

  /// The package of the font.
  final Package package;

  /// The key of the font.
  ///
  /// If you want to use it in application, you need use [assetKey].
  final String key;

  /// The font style.
  ///
  /// See [FontStyle] for more information.
  final FontStyle style;

  /// Normal is 400.
  ///
  /// The value range is between 100 with 900.
  final int weight;

  /// You can use it in your Flutter application.
  String get assetKey => 'packages/${package.name}/$key';
}

/// Corresponding to the FontStyle in Flutter.
enum FontStyle {
  /// The font is normal.
  normal,

  /// The font is italic.
  italic,
}
