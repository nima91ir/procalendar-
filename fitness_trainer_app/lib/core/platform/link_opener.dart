// Opening an external link (the support channel) without adding a package.
//
// Web hands the URL to the browser. Native has no URL launcher available,
// because adding one would mean a new package and this project does not add
// them, so it reports failure and the caller offers to copy the address
// instead — the same fallback the import screen already uses for file picking.
export 'link_opener_io.dart'
    if (dart.library.html) 'link_opener_web.dart';
