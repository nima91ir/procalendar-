// Cross-platform text file save / open used by backup export & import.
//
// Web triggers a browser download / file picker; native writes and reads in
// the app documents directory (no file dialog is available without adding a
// package, which the project forbids). `pickTextFile()` returns null on
// native, where the import screen falls back to pasting the file contents.
//
// `dart.library.js_interop` also exists on Wasm builds but is not the right
// gate — use `dart.library.html`, which is true on Web and false on native,
// so web_init just swaps in the browser implementation.
export 'file_transfer_io.dart'
    if (dart.library.html) 'file_transfer_web.dart';
