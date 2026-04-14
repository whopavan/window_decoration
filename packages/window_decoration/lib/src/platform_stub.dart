// ignore_for_file: invalid_use_of_internal_member

import 'package:flutter/src/widgets/_window.dart';
import 'package:window_decoration_platform_interface/window_decoration_platform_interface.dart';
import 'package:window_decoration_web/src/window_decoration_web.dart';

/// Web platform implementation helper

WindowDecorationPlatform createPlatform(BaseWindowController controller) {
  // On web, there's no window handle
  return WindowDecorationWeb()..initialize(null);
}

String getPlatformName() => 'web';

/// Stub classes so that `is` checks in [WindowDecorationService] compile on
/// web where the real platform packages are not available.
class WindowDecorationMacOS {
  WindowDecorationMacOS._();
}

class WindowDecorationWindows {
  WindowDecorationWindows._();
}

class WindowDecorationLinux {
  WindowDecorationLinux._();
}
