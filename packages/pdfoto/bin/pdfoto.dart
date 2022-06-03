import 'dart:io';

import 'package:path/path.dart' as path;
import 'package:pdfoto/pdfoto.dart';
import 'package:pdfoto/src/extensions/extensions.dart';

const _usageText =
    '''
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

  final basePath = args.isEmpty ? Directory.current.path : args.first;
  final directory = Directory(basePath);
  final outputFile =
      File(path.join(basePath, '${path.basename(basePath)}.pdf'));
  if (!directory.existsSync()) {
    print(
      'Error: $basePath is not a directory or does not exist\n\n$_usageText',
    );
    exit(1);
  }

  final files = directory
      .listSync()
      .whereType<File>()
      .where(
        (file) =>
            Pdfoto.validPhotoExtensions.contains(path.extension(file.path)),
      )
      .map((file) => file.toXFile())
      .toList();

  if (files.isEmpty) {
    print(
      'Error: No photos found in $basePath.\n\n'
      'Accepted file extensions: '
      '${Pdfoto.validPhotoExtensions.join(', ')}',
    );
    exit(1);
  }

  print(
    'Found ${files.length} photos in $basePath.\n'
    'Generating PDF to ${outputFile.path}',
  );

  const pdfoto = Pdfoto();

  final pdfData = await pdfoto.createPdfFromFiles(files: files);
  await outputFile.writeAsBytes(pdfData);

  print('Done.');
}
