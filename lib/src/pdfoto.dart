import 'dart:io';

import 'package:intl/intl.dart';
import 'package:path/path.dart' as path;
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart';
import 'package:pdfoto/pdfoto.dart';

/// {@template pdfoto}
/// A tool for creating a PDF that showcases a set of photos.
/// {@endtemplate}
class Pdfoto {
  /// {@macro pdfoto}
  const Pdfoto(this.directory);

  final Directory directory;

  static const validPhotoExtensions = ['.jpg', '.jpeg', '.png'];

  String get _baseFileName => path.basename(directory.path);

  File get _exportFile => File(path.join(directory.path, '$_baseFileName.pdf'));

  Future<void> run() async {
    final files = directory.listSync().whereType<File>();
    final photoFiles = files
        .where(
            (file) => validPhotoExtensions.contains(path.extension(file.path)))
        .toList();

    if (photoFiles.isEmpty) {
      print('No valid photos found in $directory.');
      return;
    }

    print('Found ${photoFiles.length} photo(s) in $directory.');

    final photos = await Future.wait([
      for (final file in photoFiles) Photo.parseFile(file),
    ])
      ..sort((a, b) {
        if (a.dateTime == null) {
          return -1;
        } else if (b.dateTime == null) {
          return 1;
        } else {
          return a.dateTime!.compareTo(b.dateTime!);
        }
      });

    final pdfDoc = Document(
      title: _baseFileName,
      author: 'PDFoto',
    );

    for (final photo in photos) {
      final pdfImage = MemoryImage(await photo.file.readAsBytes());
      pdfDoc.addPage(
        Page(
          build: (context) {
            return Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  photo.name,
                  style: TextStyle(
                    fontSize: 30,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (photo.dateTime != null)
                  Text(
                    DateFormat('yyyy-MM-dd HH:mm').format(photo.dateTime!),
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                SizedBox(height: 16),
                LimitedBox(
                  maxHeight: 400,
                  child: Image(pdfImage),
                ),
                SizedBox(height: 16),
                Table(
                  children: [
                    /*
                      make: $make,
                      model: $model,
                      size: $size,
                      didUseFlash: $didUseFlash,
                      lensModel: $lensModel,
                      iso: $iso,
                      exposureTime: $exposureTime,
                      exposureTimeInSeconds: ${exposureTimeInSeconds?.toStringAsFixed(3)},
                      focalLength: $focalLength,
                      fStop: $fStop,
                      colorSpace: ${colorSpace?.name},
                    */
                    _buildPhotoPropertyTableRow(
                      label: 'Name',
                      value: photo.name,
                    ),
                    _buildPhotoPropertyTableRow(
                      label: 'Extension',
                      value: photo.fileExtension,
                    ),
                    _buildPhotoPropertyTableRow(
                      label: 'Date',
                      value: photo.dateTime == null
                          ? null
                          : DateFormat('yyyy-MM-dd HH:mm:ss')
                              .format(photo.dateTime!),
                    ),
                    _buildPhotoPropertyTableRow(
                      label: 'Make',
                      value: photo.make,
                    ),
                    _buildPhotoPropertyTableRow(
                      label: 'Model',
                      value: photo.model,
                    ),
                    _buildPhotoPropertyTableRow(
                      label: 'Lens',
                      value: photo.lensModel,
                    ),
                    _buildPhotoPropertyTableRow(
                      label: 'Size',
                      value: photo.size == null
                          ? null
                          : '${photo.size!.width}x${photo.size!.height}',
                    ),
                    _buildPhotoPropertyTableRow(
                      label: 'Color space',
                      value: photo.colorSpace?.name,
                    ),
                    _buildPhotoPropertyTableRow(
                      label: 'Flash',
                      value: photo.didUseFlash ? 'Yes' : 'No',
                    ),
                    _buildPhotoPropertyTableRow(
                      label: 'ISO',
                      value: photo.iso?.toString(),
                    ),
                    _buildPhotoPropertyTableRow(
                      label: 'Exposure time',
                      value: photo.exposureTime?.toString(),
                    ),
                    _buildPhotoPropertyTableRow(
                      label: 'Focal length',
                      value: photo.focalLength?.toString(),
                    ),
                    _buildPhotoPropertyTableRow(
                      label: 'F-stop',
                      value: photo.fStop?.toString(),
                    ),
                  ],
                ),
              ],
            );
          },
        ),
      );
    }

    await _exportFile.writeAsBytes(await pdfDoc.save());
  }

  TableRow _buildPhotoPropertyTableRow({required String label, String? value}) {
    return TableRow(
      children: [
        Text(
          label,
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          value ?? 'Unknown',
          style: value != null
              ? null
              : TextStyle(
                  color: PdfColors.grey,
                  fontStyle: FontStyle.italic,
                ),
        ),
      ],
    );
  }
}
