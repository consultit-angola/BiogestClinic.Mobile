import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('source files do not contain common mojibake sequences', () {
    final roots = ['lib', 'test'];
    final extensions = {'.dart', '.yaml', '.yml', '.json', '.md'};
    final mojibakePattern = RegExp('[\\u00C3\\u00C2\\uFFFD]');
    final invalidFiles = <String>[];

    for (final root in roots) {
      final directory = Directory(root);
      if (!directory.existsSync()) continue;

      final files = directory.listSync(recursive: true).whereType<File>();
      for (final file in files) {
        if (!extensions.any((extension) => file.path.endsWith(extension))) {
          continue;
        }

        final content = utf8.decode(
          file.readAsBytesSync(),
          allowMalformed: true,
        );
        if (mojibakePattern.hasMatch(content)) {
          invalidFiles.add(file.path);
        }
      }
    }

    expect(invalidFiles, isEmpty);
  });
}
