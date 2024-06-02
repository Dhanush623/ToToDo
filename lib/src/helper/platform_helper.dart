import 'dart:io';
import 'package:flutter/foundation.dart' show kDebugMode;

String getCurrentPlatform() {
  String mode = kDebugMode ? 'Debug' : 'Release';

  if (Platform.isAndroid) {
    return 'Android - $mode';
  } else if (Platform.isIOS) {
    return 'iOS - $mode';
  } else if (Platform.isMacOS) {
    return 'macOS - $mode';
  } else if (Platform.isWindows) {
    return 'Windows - $mode';
  } else if (Platform.isLinux) {
    return 'Linux - $mode';
  } else if (Platform.isFuchsia) {
    return 'Fuchsia - $mode';
  } else {
    return 'Unknown Platform - $mode';
  }
}
