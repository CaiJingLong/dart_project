import 'dart:io';

import 'package:project/project.dart';
import 'package:test/test.dart';

void main() {
  group('Current project test', () {
    Package project;

    setUp(() {
      project = Package(Directory('.'));
    });

    test('Project name', () {
      expect(project.name, 'project');
    });

    test('Project dependencies', () {
      final deps = project.dependencies;

      expect(deps[0].name, 'yaml');
      expect(deps[1].name, 'path');

      expect(deps[0].type, DependencyType.pub);
      expect(deps[1].type, DependencyType.pub);
    });

    test('Project dev_dependencies', () {
      final deps = project.devDependencies;

      expect(deps[0].name, 'pedantic');
      expect(deps[1].name, 'test');

      expect(deps[0].type, DependencyType.pub);
      expect(deps[1].type, DependencyType.pub);

      print(deps[0].version);
    });
  });
}
