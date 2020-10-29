import 'dart:io';

import 'package:analyzer/dart/analysis/analysis_context_collection.dart';
import 'package:analyzer/dart/ast/ast.dart';

class SourceUtils {
  static bool containsMethod(File file, String methodName) {
    var path = file.absolute.path;
    final files = [path];
    final contextCollection = AnalysisContextCollection(includedPaths: files);

    final context = contextCollection.contextFor(path);

    final result = context.currentSession.getParsedUnit(path);

    final unit = result.unit;
    for (final child in unit.childEntities) {
      if (child is FunctionDeclaration) {
        if (child.name.name == methodName) {
          return true;
        }
      }
    }

    return false;
  }
}
