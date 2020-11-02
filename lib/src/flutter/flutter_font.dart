import 'package:meta/meta.dart';
import 'package:yaml/yaml.dart';

/// Describes all the flutter fonts in a package.
class FlutterFonts {
  final YamlList list;

  FlutterFonts({YamlList list}) : list = list;

  List<FlutterFont> get fonts {
    final result = <FlutterFont>[];

    if (list == null) {
      return result;
    }

    for (final node in list) {
      final String family = node['family'];

      final font = FlutterFont(familyName: family);

      final YamlList assets = node['fonts'];

      for (final asset in assets) {
        final flutterFontAsset = FlutterFontAsset.fromYamlNode(asset);
        font.add(flutterFontAsset);
      }

      result.add(font);
    }

    return result;
  }
}

/// Describes an font of the Flutter.
class FlutterFont {
  /// The family name of the font.
  final String familyName;

  /// The assets of the font.
  final List<FlutterFontAsset> assets = <FlutterFontAsset>[];

  FlutterFont({
    @required this.familyName,
  });

  void add(FlutterFontAsset flutterFontAsset) {
    assets.add(flutterFontAsset);
  }
}

/// An asset used to describe a font.
class FlutterFontAsset {
  final String assetKey;
  final FontStyle style;

  /// Normal is 400.
  ///
  /// The value range is between 100 with 900.
  final int weight;

  /// Create an instance of [FlutterFontAsset].
  FlutterFontAsset({
    @required this.assetKey,
    this.style = FontStyle.normal,
    this.weight = 400,
  });

  /// Create [FlutterFontAsset] instance from yaml node data.
  static FlutterFontAsset fromYamlNode(assetNode) {
    if (assetNode == null) {
      return null;
    }

    if (assetNode is String) {
      return FlutterFontAsset(assetKey: assetNode);
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
        assetKey: key,
        weight: weight,
        style: fontStyle,
      );
    }

    return null;
  }
}

/// Corresponding to the FontStyle in Flutter.
enum FontStyle {
  /// The font is normal.
  normal,

  /// The font is italic.
  italic,
}
