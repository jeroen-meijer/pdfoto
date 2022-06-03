import 'dart:io';

import 'package:cross_file/cross_file.dart';
import 'package:equatable/equatable.dart';
import 'package:exif/exif.dart';
import 'package:intl/intl.dart';
import 'package:meta/meta.dart';
import 'package:path/path.dart' as path;

/// {@template photo}
/// A single photo.
///
/// This class contains various metadata about the photo, including the file and
/// EXIF data.
/// {@endtemplate}
@immutable
class Photo extends Equatable {
  /// {@macro photo}
  const Photo({
    required this.file,
    required Map<String, IfdTag> metadata,
  }) : _metadata = metadata;

  /// Parses the given [file] into a [Photo].
  static Future<Photo> parseFile(XFile file) async {
    return Photo(
      file: file,
      metadata: await readExifFromBytes(await file.readAsBytes()),
    );
  }

  /// The file that this photo references.
  final XFile file;
  final Map<String, IfdTag> _metadata;

  String get _baseFileName => file.name;
  String get _fullFileExtension => path.extension(_baseFileName);

  /// The upper-cased file extension of the photo, without a leading dot
  /// (`"JPG"`).
  String get fileExtension => _fullFileExtension.substring(1).toUpperCase();

  /// The name of the photo, without the file extension.
  ///
  /// This is based on the file name, but with the file extension removed.
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

  /// The date and time the photo was taken.
  ///
  /// Note that this value is not always available, and is not time-zone-aware.
  DateTime? get dateTime => _mapProperty<DateTime?>(
        'Image DateTime',
        (v) {
          try {
            return DateFormat('yyyy:MM:dd HH:mm:ss').parse(v);
          } catch (_) {
            return null;
          }
        },
      );

  /// The make or brand of the camera that took the photo.
  ///
  /// Note that this value is not always available.
  String? get make => _getProperty('Image Make');

  /// The model of the camera that took the photo.
  ///
  /// Note that this value is not always available.
  String? get model => _getProperty('Image Model');

  /// The size (or resolution) of the photo in pixels.
  ///
  /// Note that this value is not always available.
  PhotoSize? get size {
    final width = _mapProperty<int?>('EXIF ExifImageWidth', int.tryParse);
    final height = _mapProperty<int?>('EXIF ExifImageLength', int.tryParse);
    if (width == null || height == null) {
      return null;
    }
    return PhotoSize(width, height);
  }

  /// The model of the lens that took the photo.
  ///
  /// Note that this value is not always available.
  String? get lensModel => _getProperty('EXIF LensModel');

  /// The ISO value used to take the photo.
  ///
  /// Note that this value is not always available.
  int? get iso => _mapProperty<int?>('EXIF ISOSpeedRatings', int.tryParse);

  /// The exposure time or shutter speed of the photo, as reported by the
  /// camera.
  ///
  /// This may either be in seconds (`"10"`) or in fractions of a second
  /// (`"1/80"`).
  ///
  /// Note that this value is not always available.
  String? get exposureTime => _getProperty('EXIF ExposureTime');

  /// The exposure time in seconds.
  ///
  /// This is based on the [exposureTime]. If the [exposureTime] is a fraction,
  /// this will be the result of calculating the fraction (`"1/80"` exposure
  /// time means this value will be `0.0125`).
  ///
  /// Note that this value is not always available.
  double? get exposureTimeInSeconds {
    final asString = exposureTime;
    if (asString == null) {
      return null;
    }

    final parts = asString.split('/');
    if (parts.length == 1) {
      return double.tryParse(parts[0]);
    } else if (parts.length != 2) {
      return null;
    }

    final numerator = double.tryParse(parts[0]);
    final denominator = double.tryParse(parts[1]);
    if (numerator == null || denominator == null) {
      return null;
    }

    return numerator / denominator;
  }

  /// The focal length in millimeters of the lens that took the photo.
  ///
  /// Note that this value is not always available.
  double? get focalLength => _mapProperty<double?>(
        'EXIF FocalLength',
        (v) => double.tryParse(v.replaceAll('mm', '').trim()),
      );

  /// The f-stop value of the lens that took the photo.
  ///
  /// Note that this value is not always available.
  String? get fStop => _getProperty('EXIF FNumber');

  /// Whether the photo was taken with a flash.
  ///
  /// If this value is not available, it will default to `false`.
  bool get didUseFlash =>
      _getProperty('EXIF Flash')?.toLowerCase().contains('fired') ?? false;

  /// The color space of the photo.
  ///
  /// If no color space is available, this will be `null`. If the specified
  /// color space is not supported, this will return [PhotoColorSpace.unknown].
  ///
  /// Note that this value is not always available.
  PhotoColorSpace? get colorSpace => _mapProperty<PhotoColorSpace?>(
        'EXIF ColorSpace',
        (v) => PhotoColorSpace.values.cast<PhotoColorSpace?>().firstWhere(
              (c) => v == c!.name,
              orElse: () => PhotoColorSpace.unknown,
            ),
      );

  @override
  String toString() =>
      '''
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

  @override
  List<Object?> get props => [
        file,
        {for (final key in _metadata.keys) _getProperty(key)}
      ];
}

/// {@template photo_size}
/// A size of a photo in pixels.
///
/// Contains a width and height. Both values are required and may not be less
/// than zero.
/// {@endtemplate}
@immutable
class PhotoSize {
  /// {@macro photo_size}
  const PhotoSize(this.width, this.height)
      : assert(width >= 0, 'Width must be greater than or equal to zero.'),
        assert(height >= 0, 'Height must be greater than or equal to zero.');

  /// The width of the photo in pixels.
  final int width;

  /// The height of the photo in pixels.
  final int height;

  @override
  String toString() => 'Size(${width}x$height)';
}

/// The RGB color space of a photo.
enum PhotoColorSpace {
  /// The photo is in the sRGB color space.
  sRGB,

  /// The photo is in the Adobe RGB color space.
  adobeRGB,

  /// The photo is in an unknown color space.
  unknown,
}
