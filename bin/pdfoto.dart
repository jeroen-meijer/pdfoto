import 'dart:io';

import 'package:pdfoto/pdfoto.dart';

const _usageText = '''
Usage:
  pdfoto <directory>

If no directory is specified, the current directory is used.
The PDF is saved to <directory>/<directory name>.pdf.
''';

Future<void> main(List<String> args) async {
  if (args.length > 1) {
    print(_usageText);
    exit(1);
  }

  final path = args.isEmpty ? 'bin/pdfoto.dart' : args.first;
  final directory = Directory(path);
  if (!directory.existsSync()) {
    print('Error: $path is not a directory or does not exist\n\n$_usageText');
    exit(1);
  }

  try {
    await Pdfoto(directory).run();
  } catch (e) {
    print('Error: $e');
    exit(1);
  }
}
