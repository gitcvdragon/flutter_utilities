// Dart imports:
import 'dart:io';

// Package imports:
import 'package:file_picker/file_picker.dart';

Future<List<File>> pickFiles({
  bool allowMultiple = true,
  List<String>? allowedExtensions,
}) async {
  return FilePicker.platform
      .pickFiles(
        type: (allowedExtensions != null) ? FileType.custom : FileType.any,
        allowMultiple: allowMultiple,
        allowedExtensions: allowedExtensions,
      )
      .then(
        (result) => (result ?? const FilePickerResult([]))
            .paths
            .map((path) => File(path!))
            .toList(),
      );
}
