// ignore_for_file: invalid_use_of_internal_member, implementation_imports

export 'src/widgets.dart';
export 'src/macos_extra.dart';
export 'src/win32_extra.dart';
export 'src/linux_extra.dart';
export 'src/effects/ns_visual_effect.dart';
export 'src/effects/dwm_effects.dart';
export 'src/decorated_window.dart'
    show DecoratedWindow, WindowEdge;
export 'src/decorated_window_macos.dart' show DecoratedWindowMacOS;
export 'src/decorated_window_win32.dart' show DecoratedWindowWin32;
export 'src/decorated_window_linux.dart' show DecoratedWindowLinux;

import 'src/decorated_window.dart';
import 'package:flutter/src/widgets/_window.dart';

/// Enables window decoration features on a [BaseWindowController].
///
/// Call this once per controller after construction. Afterwards, widgets like
/// [WindowDragArea], [WindowTrafficLight], [CloseButton], [MinimizeButton],
/// [MaximizeButton], and [WindowBorder] become functional for this window.
///
/// Platform-specific customization is reached via [DecoratedWindow.forController]
/// and downcasting to [DecoratedWindowMacOS], [DecoratedWindowWin32], or
/// [DecoratedWindowLinux].
extension DecoratedWindowExtension on BaseWindowController {
  void enableDecoratedWindow() {
    DecoratedWindow.init(this);
  }
}
