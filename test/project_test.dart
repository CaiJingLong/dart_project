import 'dart:io';

import 'package:project/project.dart';
import 'package:test/test.dart';

void main() {
  group('FileSytemEntity extension test group: ', () {
    test('FileSytemEntity test', () {
      expect(FileSystemEntity.identicalSync('lib/', 'lib'), true);

      expect(Directory('lib').name, 'lib');
      expect(Directory('lib/').name, 'lib');
      expect(File('pubspec.yaml').name, 'pubspec.yaml');

      expect(Directory('lib/').identicalOther(Directory('lib/')), true);

      final relative = File('lib/project.dart').relativeOther(
        Directory('example/example.dart'),
      );
      expect(relative, '../../lib/project.dart');
    });

    test('Directory test', () {
      final directory = Directory('.');
      final libDir = directory.childDir('lib/');
      expect(libDir.identicalOther(Directory('lib')), true);

      final example1 = directory.child('example/example.dart');
      final example2 = directory.childDir('example').child('example.dart');

      expect(example1.identicalOther(example2), true);
    });
  });

  group('Current library', () {
    Package package;

    setUp(() {
      package = Package(Directory('.'));
    });

    test('basic information', () {
      expect(package != null, true);
      expect(package.name, 'project');
      expect(package.isFlutter, false);
      expect(package.packageDir.existsSync(), true);
      expect(package.yamlFile.existsSync(), true);
      expect(package.rootPackage, package);
    });

    test('dependencies', () {
      final deps = package.dependencies;

      expect(deps[0].name, 'yaml');
      expect(deps[1].name, 'path');

      expect(deps[0].type, DependencyType.pub);
      expect(deps[1].type, DependencyType.pub);

      final dep1 = deps[0];
      expect(dep1.name, 'yaml');

      for (final dep in deps) {
        expect(dep.rootPackage, package);
        expect(dep.package.rootPackage, package);
      }
    });

    test('dev_dependencies', () {
      final deps = package.devDependencies;

      expect(deps[0].name, 'pedantic');
      expect(deps[1].name, 'test');

      expect(deps[0].type, DependencyType.pub);
      expect(deps[1].type, DependencyType.pub);

      for (final dep in deps) {
        expect(dep.rootPackage, package);
        expect(dep.package.rootPackage, package);
      }
    });

    test('Sources', () {
      final dartSources = package.dartSources;

      expect(dartSources.isNotEmpty, true);

      for (final dartFile in dartSources) {
        expect(dartFile.name.endsWith('.dart'), true);
      }
    });
  });

  group('Flutter project', () {
    Package package;
    setUp(() {
      package = Package.fromPath('example/flutter_project');
    });

    test('basic information', () {
      expect(package.name, 'flutter_project');
      expect(package.isFlutter, true);

      final flutterInfo = package.flutterInfo;
      expect(flutterInfo.useMaterialDesign, true);

      expect(flutterInfo.isPlugin, false);
      expect(flutterInfo.haveAndroid, true);
      expect(flutterInfo.haveIOS, true);
      expect(flutterInfo.haveMacOS, true);
      expect(flutterInfo.haveWeb, true);
      expect(flutterInfo.haveLinux, false);
      expect(flutterInfo.haveWindows, false);
    });

    test('plugin dependency', () {
      final dep = package.getDependency('flutter_plugin');
      expect(dep.name, 'flutter_plugin');
      final pkg = dep.package;
      expect(pkg.name, 'flutter_plugin');
      expect(pkg.version, '0.0.1');

      expect(pkg.isFlutter, true);

      final flutterInfo = pkg.flutterInfo;
      expect(flutterInfo.isApplication, false);
      expect(flutterInfo.isPlugin, true);
    });

    test('analysis', () {
      final flutterInfo = package.flutterInfo;
      expect(flutterInfo.isApplication, true);
    });

    test('assets', () {
      final flutterInfo = package.flutterInfo;
      final assets = flutterInfo.assets;

      expect(assets.length, 2);

      final asset = assets[0];

      final variants = asset.getVariants();
      expect(variants.length, 2);

      expect(variants.containsKey('default'), true);
      expect(variants.containsKey('2.0x'), true);
      expect(variants.containsKey('3.0x'), false);

      expect(asset.assetKey, 'assets/images/download.png');

      final pluginDep = package.dependencies.firstWhere(
        (element) => element.name == 'flutter_plugin',
        orElse: () => null,
      );
      final pluginPkg = pluginDep.package;

      expect(pluginPkg.isFlutter, true);
      final pluginInfo = pluginPkg.flutterInfo;
      final pluginAssets = pluginInfo.assets;
      expect(pluginAssets.length, 1);
    });

    test('fonts', () {
      final flutterInfo = package.flutterInfo;
      expect(flutterInfo.containsFonts(), false);

      final pluginDep = package.dependencies.firstWhere(
        (element) => element.name == 'flutter_plugin',
        orElse: () => null,
      );

      final pluginPkg = pluginDep.package;
      expect(pluginPkg.isFlutter, true);
      final pluginInfo = pluginPkg.flutterInfo;

      expect(pluginInfo.containsFonts(), true);

      final fonts = pluginInfo.fonts;
      final fontList = fonts.fonts;

      expect(fontList.length, 1);
      final font = fontList[0];

      final fontAsset = font.assets;

      expect(fontAsset.length, 2);
      final asset0 = fontAsset[0];

      expect(asset0.style, FontStyle.normal);
      expect(asset0.weight, 400);

      final asset1 = fontAsset[1];
      expect(asset1.style, FontStyle.normal);
      expect(asset1.weight, 800);
    });
  });
}
