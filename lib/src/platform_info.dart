// Dart imports:
import 'dart:io' show Platform;

// Flutter imports:
import 'package:flutter/foundation.dart' show kIsWeb;

bool get isDesktop {
  if (!kIsWeb) {
    return Platform.isWindows || Platform.isLinux || Platform.isMacOS;
  }
  return false;
}

bool get isAndroid {
  if (!kIsWeb) {
    return Platform.isAndroid;
  }
  return false;
}

bool get isIOS {
  if (!kIsWeb) {
    return Platform.isIOS;
  }
  return false;
}

bool get isSmartPhone {
  if (!kIsWeb) {
    return Platform.isAndroid || Platform.isFuchsia || Platform.isIOS;
  }
  return false;
}

bool get isWeb => kIsWeb;
