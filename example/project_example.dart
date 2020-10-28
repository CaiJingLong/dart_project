import 'package:project/project.dart';

Set<String> names = {};

void main() {
  final rootPkg = Package.fromPath('.');

  printPktInfo(rootPkg, 1);
}

String tab(int level) {
  return '  ' * level;
}

void printPktInfo(Package pkg, int level) {
  final name = pkg.name;
  print('${tab(level - 1)}${name}: ');
  if (names.contains(name)) {
    return;
  }
  names.add(name);
  final space = tab(level);
  // print('${space}version: ${pkg.version}');
  // print('${space}description: ${pkg.description}');
  // print('${space}local path: ${pkg.packageDir.path}');

  for (var dependency in pkg.dependencies) {
    final pkg = dependency.package;
    printPktInfo(pkg, level + 1);
  }

  for (var dependency in pkg.devDependencies) {
    final pkg = dependency.package;
    printPktInfo(pkg, level + 1);
  }
}
