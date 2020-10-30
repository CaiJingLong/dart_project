# dart_project

The goal of this library is to parse Dart's project with a simple API.

This library can help developers who develop flutter write useful tools more easily.

## Import

```yaml
dependencies:
  project: $latest_version
```

```dart
import 'package:project/project.dart';
```

## Usage

See [example][] or [test.dart][].

Example 1:

```dart
final package = Package.fromPath('.');

print(package.name);
print(package.version);
print(package.yamlFile.path);
print(package.isFlutter);

final deps = package.dependencies;

for(final dep in deps) {
  print('${dep.name}');
}

if(package.isFlutter) {
  final flutterInfo = package.flutterInfo;
  print(flutterInfo.useMaterialDesign);
  print(flutterInfo.haveAndroid);
}
```

Example 2:

like use `flutter pub deps` or `pub deps`.

```dart
import 'package:project/project.dart';

Set<String> names = {};

void main() {
  final rootPkg = Package.fromPath('.');

  printPktInfo(rootPkg, 1, false);
}

String tab(int level) {
  if (level == 0) {
    return '';
  }

  return ('|  ' * (level - 1)) + '|--';
}

void printPktInfo(Package pkg, int level, [bool showInfo = true]) {
  final name = pkg.name;
  final ouputName = '${tab(level - 1)}${name}: ';
  if (names.contains(name)) {
    print('$ouputName ...');
    return;
  }
  print('$ouputName${pkg.version}');

  names.add(name);
  final space = tab(level);
  // print('${space}version: ${pkg.version}');
  if (showInfo) {
    print('${space}description: ${pkg.description}');
    print('${space}local path: ${pkg.packageDir.path}');
  }

  for (var dependency in pkg.dependencies) {
    final pkg = dependency.package;
    printPktInfo(pkg, level + 1, showInfo);
  }

  for (var dependency in pkg.devDependencies) {
    final subPkg = dependency.package;
    if (subPkg == null) {
      continue;
    }
    printPktInfo(subPkg, level + 1, showInfo);
  }
}
```

## LICENSE

BSD 3.0 Style.

[example]: https://github.com/CaiJingLong/dart_project/blob/main/example/example.dart
[test.dart]: https://github.com/CaiJingLong/dart_project/blob/main/test/project_test.dart
