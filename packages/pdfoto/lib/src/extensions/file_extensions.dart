import 'dart:io';

import 'package:cross_file/cross_file.dart';

/// Extensions on [File] for convenience.
extension FileExtensions on File {
  /// Returns a [XFile] object for the file.
  XFile toXFile() {
    return XFile(path);
  }
}
