// ignore_for_file: avoid_web_libraries_in_flutter, deprecated_member_use
import 'dart:async';
import 'dart:convert';
import 'dart:html' as html;

bool get isFilePickerSupported => true;

/// Whether [saveTextFile] returning a value proves the file exists.
///
/// It does **not** on the web: `anchor.click()` only *starts* a download, and
/// no browser API reports whether the user accepted, finished, or cancelled it.
/// A non-null result therefore means "asked", not "saved". Callers that depend
/// on the file actually existing — the destructive-restore safety copy in
/// `import_backup_screen` — must warn instead of trusting it.
const bool kFileSaveIsVerifiable = false;

/// Triggers a browser download. Returns the file name (there is no path).
Future<String?> saveTextFile(String fileName, String contents) async {
  final blob = html.Blob([utf8.encode(contents)], 'application/octet-stream');
  final url = html.Url.createObjectUrlFromBlob(blob);
  final anchor = html.AnchorElement(href: url)
    ..download = fileName
    ..style.display = 'none';
  html.document.body!.append(anchor);
  anchor.click();
  anchor.remove();
  html.Url.revokeObjectUrl(url);
  return fileName;
}

/// Opens the browser file picker and resolves with the file text, or null when
/// the user cancelled.
Future<String?> pickTextFile() async {
  final input = html.FileUploadInputElement()
    ..accept = '.json,application/json,text/plain'
    ..style.display = 'none';
  final completer = Completer<String?>();
  input.onChange.listen((_) async {
    final files = input.files;
    if (files == null || files.isEmpty) {
      completer.complete(null);
      return;
    }
    final reader = html.FileReader();
    reader.readAsText(files.first);
    await reader.onLoad.first;
    completer.complete(reader.result as String?);
  });
  html.document.body!.append(input);
  input.click();
  return completer.future;
}
