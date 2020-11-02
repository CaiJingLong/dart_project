import 'package:project/project.dart';

Set<String> names = {};

/// The file will output some info: see [example.log][]
///
/// [example.log]: https://github.com/CaiJingLong/dart_project/blob/main/example/example.log
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
