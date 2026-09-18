import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

/// Native has no built-in file picker (a package would be required).
bool get isFilePickerSupported => false;

/// Writes [contents] to [fileName] in the app documents directory and returns
/// the absolute path, so the UI can show the user where the file landed.
Future<String?> saveTextFile(String fileName, String contents) async {
  final dir = await getApplicationDocumentsDirectory();
  final file = File(p.join(dir.path, fileName));
  await file.writeAsString(contents);
  return file.path;
}

Future<String?> pickTextFile() async => null;
