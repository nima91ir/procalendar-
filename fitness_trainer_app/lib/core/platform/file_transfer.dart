// Cross-platform text file save / open used by backup export & import.
//
// Web triggers a browser download / file picker; native writes and reads in
// the app documents directory (no file dialog is available without adding a
// package, which the project forbids). `pickTextFile()` returns null on
// native, where the import screen falls back to pasting the file contents.
export 'file_transfer_io.dart'
    if (dart.library.js_interop) 'file_transfer_web.dart';
