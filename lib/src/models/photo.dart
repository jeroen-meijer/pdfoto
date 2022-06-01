import 'dart:io';

import 'package:exif/exif.dart';
import 'package:intl/intl.dart';
import 'package:meta/meta.dart';
import 'package:path/path.dart' as path;

@immutable
class Photo {
  const Photo({
    required this.file,
    required Map<String, IfdTag> metadata,
  }) : _metadata = metadata;

  static Future<Photo> parseFile(File file) async {
    return Photo(
      file: file,
      metadata: await readExifFromBytes(await file.readAsBytes()),
    );
  }

  final File file;
  final Map<String, IfdTag> _metadata;

  String get _baseFileName => path.basename(file.path);
  String get _fullFileExtension => path.extension(_baseFileName);

  String get fileExtension => _fullFileExtension.substring(1).toUpperCase();
  String get name =>
      _baseFileName.substring(0, _baseFileName.lastIndexOf(_fullFileExtension));

  T? _mapProperty<T>(String key, T Function(String) mapper) {
    final value = _metadata[key]?.printable.trim();
    if (value == null) {
      return null;
    }
    return mapper(value);
  }

  String? _getProperty(String key) =>
      _mapProperty<String?>(key, (v) => v.isEmpty ? null : v);

  DateTime? get dateTime =>
      _mapProperty<DateTime?>('EXIF DateTimeOriginal', (v) {
        try {
          return DateFormat('yyyy:MM:dd HH:mm:ss').parse(v);
        } catch (_) {
          return null;
        }
      });

  String? get make => _getProperty('Image Make');

  String? get model => _getProperty('Image Model');

  Size? get size {
    final width = _mapProperty<int?>('EXIF ExifImageWidth', int.tryParse);
    final height = _mapProperty<int?>('EXIF ExifImageLength', int.tryParse);
    if (width == null || height == null) {
      return null;
    }
    return Size(width, height);
  }

  String? get lensModel => _getProperty('EXIF LensModel');

  int? get iso => _mapProperty<int?>('EXIF ISOSpeedRatings', int.tryParse);

  String? get exposureTime => _getProperty('EXIF ExposureTime');

  double? get exposureTimeInSeconds {
    final parts = exposureTime?.split('/');
    if (parts == null || parts.length != 2) {
      return null;
    }

    final numerator = double.tryParse(parts[0]);
    final denominator = double.tryParse(parts[1]);
    if (numerator == null || denominator == null) {
      return null;
    }

    return numerator / denominator;
  }

  double? get focalLength => _mapProperty<double?>(
        'EXIF FocalLength',
        (v) => double.tryParse(v.replaceAll('mm', '').trim()),
      );

  String? get fStop => _getProperty('EXIF FNumber');

  bool get didUseFlash =>
      _getProperty('EXIF Flash')?.toLowerCase().contains('fired') ?? false;

  PhotoColorSpace? get colorSpace => _mapProperty<PhotoColorSpace?>(
        'EXIF ColorSpace',
        (v) => PhotoColorSpace.values.cast<PhotoColorSpace?>().firstWhere(
              (c) => v == c!.name,
              orElse: () => null,
            ),
      );

  @override
  String toString() => '''
Photo(
  name: $name,
  fileExtension: $fileExtension,
  path: ${file.path},
  dateTime: $dateTime,
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
)''';
}

@immutable
class Size {
  const Size(this.width, this.height);

  final int width;
  final int height;

  @override
  String toString() => 'Size(${width}x$height)';
}

enum PhotoColorSpace {
  sRGB,
  adobeRGB,
  unknown,
}
