// ignore_for_file: invalid_use_of_internal_member, implementation_imports

import 'dart:io' show Platform;

import 'package:ffi/ffi.dart';
import 'package:flutter/src/widgets/_window_linux.dart';
import 'package:flutter/widgets.dart';

import 'decorated_window.dart';
import 'dart:ffi' as ffi;
import 'linux.g.dart';

final _gtkLib = ffi.DynamicLibrary.process();

@ffi.Native<ffi.Void Function(ffi.Pointer<ffi.NativeType>)>(
  symbol: 'gtk_window_close',
)
external void _gtkWindowClose(ffi.Pointer<ffi.NativeType> window);

final _gtkWindowSetKeepAbove = _gtkLib.lookupFunction<
  ffi.Void Function(ffi.Pointer<ffi.Void>, ffi.Int32),
  void Function(ffi.Pointer<ffi.Void>, int)
>('gtk_window_set_keep_above');

final _gtkWindowSetSkipTaskbarHint = _gtkLib.lookupFunction<
  ffi.Void Function(ffi.Pointer<ffi.Void>, ffi.Int32),
  void Function(ffi.Pointer<ffi.Void>, int)
>('gtk_window_set_skip_taskbar_hint');

final _gtkWindowSetOpacity = _gtkLib.lookupFunction<
  ffi.Void Function(ffi.Pointer<ffi.Void>, ffi.Double),
  void Function(ffi.Pointer<ffi.Void>, double)
>('gtk_widget_set_opacity');

final _gtkWidgetShow = _gtkLib.lookupFunction<
  ffi.Void Function(ffi.Pointer<ffi.Void>),
  void Function(ffi.Pointer<ffi.Void>)
>('gtk_widget_show');

final _gtkWidgetHide = _gtkLib.lookupFunction<
  ffi.Void Function(ffi.Pointer<ffi.Void>),
  void Function(ffi.Pointer<ffi.Void>)
>('gtk_widget_hide');

final _gtkWindowPresent = _gtkLib.lookupFunction<
  ffi.Void Function(ffi.Pointer<ffi.Void>),
  void Function(ffi.Pointer<ffi.Void>)
>('gtk_window_present');

final _gtkWindowMove = _gtkLib.lookupFunction<
  ffi.Void Function(ffi.Pointer<ffi.Void>, ffi.Int32, ffi.Int32),
  void Function(ffi.Pointer<ffi.Void>, int, int)
>('gtk_window_move');

final _gtkWindowGetPosition = _gtkLib.lookupFunction<
  ffi.Void Function(
    ffi.Pointer<ffi.Void>,
    ffi.Pointer<ffi.Int32>,
    ffi.Pointer<ffi.Int32>,
  ),
  void Function(
    ffi.Pointer<ffi.Void>,
    ffi.Pointer<ffi.Int32>,
    ffi.Pointer<ffi.Int32>,
  )
>('gtk_window_get_position');

final _gtkWindowGetSize = _gtkLib.lookupFunction<
  ffi.Void Function(
    ffi.Pointer<ffi.Void>,
    ffi.Pointer<ffi.Int32>,
    ffi.Pointer<ffi.Int32>,
  ),
  void Function(
    ffi.Pointer<ffi.Void>,
    ffi.Pointer<ffi.Int32>,
    ffi.Pointer<ffi.Int32>,
  )
>('gtk_window_get_size');

final _gdkScreenGetDefault = _gtkLib.lookupFunction<
  ffi.Pointer<ffi.Void> Function(),
  ffi.Pointer<ffi.Void> Function()
>('gdk_screen_get_default');

final _gdkScreenGetWidth = _gtkLib.lookupFunction<
  ffi.Int32 Function(ffi.Pointer<ffi.Void>),
  int Function(ffi.Pointer<ffi.Void>)
>('gdk_screen_get_width');

final _gdkScreenGetHeight = _gtkLib.lookupFunction<
  ffi.Int32 Function(ffi.Pointer<ffi.Void>),
  int Function(ffi.Pointer<ffi.Void>)
>('gdk_screen_get_height');

class DecoratedWindowLinux extends DecoratedWindow {
  DecoratedWindowLinux(this.controller) {
    cw_gtk_window_remove_decorations(
      controller.windowHandle,
      controller.flutterViewHandle,
    );
    cw_init_event_hooks_if_needed();
  }

  final WindowControllerLinux controller;

  ffi.Pointer<ffi.Void> get _window => controller.windowHandle;

  @override
  void requestClose() {
    _gtkWindowClose(controller.windowHandle);
  }

  @override
  void setDragExcludeRectForElement(BuildContext element, Rect? rect) {}

  @override
  void setDraggableRectForElement(BuildContext element, Rect? rect) {}

  @override
  void setMaximizeButtonFrame(BuildContext element, Rect? rect) {}

  @override
  void setTrafficLightPosition(Offset offset) {}

  @override
  Size getTrafficLightSize() {
    return Size.zero;
  }

  @override
  bool windowNeedsMoveDragDetector() {
    return true;
  }

  @override
  bool windowNeedsCustomBorder() {
    return true;
  }

  @override
  bool titlebarNeedsDoubleClickDetector() {
    return true;
  }

  @override
  void setCustomBorderShadowWidth(
    double top,
    double left,
    double bottom,
    double right,
  ) {
    cw_window_set_shadow_width(
      _window,
      top.round(),
      left.round(),
      bottom.round(),
      right.round(),
    );
  }

  @override
  void startWindowMoveDrag(Offset globalPosition) {
    cw_window_begin_move_drag(
      _window,
      globalPosition.dx.round(),
      globalPosition.dy.round(),
    );
  }

  @override
  void startWindowResizeDrag(Offset globalPosition, WindowEdge edge) {
    final gtkEdge = switch (edge) {
      WindowEdge.northWest => cw_window_edge_t.CW_WINDOW_EDGE_NORTH_WEST,
      WindowEdge.north => cw_window_edge_t.CW_WINDOW_EDGE_NORTH,
      WindowEdge.northEast => cw_window_edge_t.CW_WINDOW_EDGE_NORTH_EAST,
      WindowEdge.west => cw_window_edge_t.CW_WINDOW_EDGE_WEST,
      WindowEdge.east => cw_window_edge_t.CW_WINDOW_EDGE_EAST,
      WindowEdge.southWest => cw_window_edge_t.CW_WINDOW_EDGE_SOUTH_WEST,
      WindowEdge.south => cw_window_edge_t.CW_WINDOW_EDGE_SOUTH,
      WindowEdge.southEast => cw_window_edge_t.CW_WINDOW_EDGE_SOUTH_EAST,
    };
    cw_window_begin_resize_drag(
      _window,
      gtkEdge,
      globalPosition.dx.round(),
      globalPosition.dy.round(),
    );
  }

  //
  // Shared feature methods.
  //

  @override
  Future<void> center() async {
    final width = malloc<ffi.Int32>();
    final height = malloc<ffi.Int32>();
    try {
      _gtkWindowGetSize(_window, width, height);
      final screen = _gdkScreenGetDefault();
      final screenWidth = _gdkScreenGetWidth(screen);
      final screenHeight = _gdkScreenGetHeight(screen);
      final x = (screenWidth - width.value) ~/ 2;
      final y = (screenHeight - height.value) ~/ 2;
      _gtkWindowMove(_window, x, y);
    } finally {
      malloc
        ..free(width)
        ..free(height);
    }
  }

  @override
  Future<Offset> getPosition() async {
    final x = malloc<ffi.Int32>();
    final y = malloc<ffi.Int32>();
    try {
      _gtkWindowGetPosition(_window, x, y);
      return Offset(x.value.toDouble(), y.value.toDouble());
    } finally {
      malloc
        ..free(x)
        ..free(y);
    }
  }

  @override
  Future<void> setPosition(Offset position) async {
    _gtkWindowMove(_window, position.dx.round(), position.dy.round());
  }

  @override
  Future<void> setBackgroundColor(Color color) async {
    // GTK window background color is handled via CSS on the Flutter view in
    // the shipped native library; no direct GTK API is available here.
  }

  @override
  Future<void> setOpacity(double opacity) async {
    _gtkWindowSetOpacity(_window, opacity.clamp(0.0, 1.0));
  }

  @override
  Future<void> setAlwaysOnTop({required bool alwaysOnTop}) async {
    _gtkWindowSetKeepAbove(_window, alwaysOnTop ? 1 : 0);
  }

  @override
  Future<void> setSkipTaskbar({required bool skip}) async {
    _gtkWindowSetSkipTaskbarHint(_window, skip ? 1 : 0);
  }

  @override
  Future<void> setVisible({required bool visible}) async {
    if (visible) {
      _gtkWidgetShow(_window);
    } else {
      _gtkWidgetHide(_window);
    }
  }

  @override
  Future<void> bringToForeground() async {
    _gtkWindowPresent(_window);
  }

  //
  // Linux-only feature methods.
  //

  /// Whether the process is running under a Wayland session.
  Future<bool> isWayland() async {
    final sessionType = Platform.environment['XDG_SESSION_TYPE'] ?? '';
    if (sessionType.toLowerCase() == 'wayland') return true;
    return Platform.environment['WAYLAND_DISPLAY']?.isNotEmpty == true;
  }

  /// Whether the process is running under an X11 session.
  Future<bool> isX11() async {
    if (await isWayland()) return false;
    final sessionType = Platform.environment['XDG_SESSION_TYPE'] ?? '';
    if (sessionType.toLowerCase() == 'x11') return true;
    return Platform.environment['DISPLAY']?.isNotEmpty == true;
  }
}
