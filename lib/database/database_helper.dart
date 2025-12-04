// Conditional exports: use the IO (sqflite) implementation on native platforms
// and the web implementation when running in the browser.
export 'database_helper_io.dart'
    if (dart.library.html) 'database_helper_web.dart';
