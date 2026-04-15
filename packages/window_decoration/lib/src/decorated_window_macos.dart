// ignore_for_file: invalid_use_of_internal_member, implementation_imports

import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';

import 'package:flutter/src/widgets/_window_macos.dart';

import 'decorated_window.dart';
import 'effects/ns_visual_effect.dart';
import 'invert_rectangles.dart';
import 'macos.g.dart';
import 'macos_extra.dart';

import 'dart:ffi' hide Size;
import 'package:ffi/ffi.dart';
import 'package:ffi/ffi.dart' as ffi;

typedef _ObjCId = Pointer<Void>;
typedef _ObjCSel = Pointer<Void>;

final _objcLib = DynamicLibrary.process();

final _selRegisterName = _objcLib
    .lookupFunction<_ObjCSel Function(Pointer<Utf8>), _ObjCSel Function(Pointer<Utf8>)>(
      'sel_registerName',
    );

final _objcGetClass = _objcLib
    .lookupFunction<_ObjCId Function(Pointer<Utf8>), _ObjCId Function(Pointer<Utf8>)>(
      'objc_getClass',
    );

final _msgSend = _objcLib
    .lookupFunction<_ObjCId Function(_ObjCId, _ObjCSel), _ObjCId Function(_ObjCId, _ObjCSel)>(
      'objc_msgSend',
    );

final _msgSendVoidBool = _objcLib.lookupFunction<
  Void Function(_ObjCId, _ObjCSel, Bool),
  void Function(_ObjCId, _ObjCSel, bool)
>('objc_msgSend');

final _msgSendVoidInt = _objcLib.lookupFunction<
  Void Function(_ObjCId, _ObjCSel, Int64),
  void Function(_ObjCId, _ObjCSel, int)
>('objc_msgSend');

final _msgSendVoidDouble = _objcLib.lookupFunction<
  Void Function(_ObjCId, _ObjCSel, Double),
  void Function(_ObjCId, _ObjCSel, double)
>('objc_msgSend');

final _msgSendVoidId = _objcLib.lookupFunction<
  Void Function(_ObjCId, _ObjCSel, _ObjCId),
  void Function(_ObjCId, _ObjCSel, _ObjCId)
>('objc_msgSend');

final _msgSendIntRet = _objcLib.lookupFunction<
  Int64 Function(_ObjCId, _ObjCSel),
  int Function(_ObjCId, _ObjCSel)
>('objc_msgSend');

final _msgSendId4Double = _objcLib.lookupFunction<
  _ObjCId Function(_ObjCId, _ObjCSel, Double, Double, Double, Double),
  _ObjCId Function(_ObjCId, _ObjCSel, double, double, double, double)
>('objc_msgSend');

_ObjCSel _sel(String name) {
  final n = name.toNativeUtf8();
  final s = _selRegisterName(n);
  ffi.malloc.free(n);
  return s;
}

_ObjCId _cls(String name) {
  final n = name.toNativeUtf8();
  final c = _objcGetClass(n);
  ffi.malloc.free(n);
  return c;
}

// NSWindowLevel constants.
const int _kNSNormalWindowLevel = 0;
const int _kNSFloatingWindowLevel = 3;

// NSApplicationActivationPolicy constants.
const int _kPolicyRegular = 0;
const int _kPolicyAccessory = 1;

class DecoratedWindowMacOS extends DecoratedWindow with WindowDelegateMacOS {
  DecoratedWindowMacOS(this.controller, {required this.onClose}) {
    cw_nswindow_remove_titlebar(controller.windowHandle);
    controller.addDelegate(this);
  }

  final VoidCallback onClose;

  @override
  void windowWillClose() {
    onClose();
  }

  final WindowControllerMacOS controller;

  _ObjCId get _nsWindow => controller.windowHandle.cast<Void>();

  @override
  Size getTrafficLightSize() {
    return const Size(54, 16);
  }

  @override
  void setTrafficLightPosition(Offset offset) {
    cw_nswindow_update_traffic_light(
      controller.windowHandle,
      true,
      offset.dx,
      offset.dy,
    );
  }

  bool _updateScheduled = false;

  void _update() {
    _updateScheduled = false;

    if (_draggableRects.isEmpty) {
      cw_nswindow_disable_draggable_areas(controller.windowHandle);
    } else {
      final view = _draggableRects.keys.first
          .findAncestorRenderObjectOfType<RenderView>();
      if (view == null) {
        throw StateError('Unexpectedly missing RenderView in heirarchy');
      }
      final bounds = Offset.zero & view.size;

      final invertedRects = invert(bounds, _draggableRects.values);
      final count = invertedRects.length + _dragExcludeRects.length;

      final rectsPointer = ffi.malloc<cw_rect_t>(count);
      for (final (index, rect)
          in invertedRects.followedBy(_dragExcludeRects.values).indexed) {
        rectsPointer[index].x = rect.left;
        rectsPointer[index].y = rect.top;
        rectsPointer[index].w = rect.width;
        rectsPointer[index].h = rect.height;
      }
      cw_nswindow_update_draggable_areas(
        controller.windowHandle,
        rectsPointer,
        count,
      );
    }
  }

  void _scheduleUpdate() {
    if (_updateScheduled) {
      return;
    }
    _updateScheduled = true;
    Future.microtask(_update);
  }

  final _draggableRects = <BuildContext, Rect>{};
  final _dragExcludeRects = <BuildContext, Rect>{};

  @override
  void setDraggableRectForElement(BuildContext element, Rect? rect) {
    if (rect != null) {
      _draggableRects[element] = rect;
    } else {
      _draggableRects.remove(element);
    }
    _scheduleUpdate();
  }

  @override
  void setDragExcludeRectForElement(BuildContext element, Rect? rect) {
    if (rect != null) {
      _dragExcludeRects[element] = rect;
    } else {
      _dragExcludeRects.remove(element);
    }
    _scheduleUpdate();
  }

  @override
  void setMaximizeButtonFrame(BuildContext element, Rect? rect) {}

  @override
  void requestClose() {
    cw_nswindow_request_close(controller.windowHandle);
  }

  @override
  bool windowNeedsMoveDragDetector() {
    return true;
  }

  @override
  bool windowNeedsCustomBorder() {
    return false;
  }

  @override
  void setCustomBorderShadowWidth(
    double top,
    double left,
    double bottom,
    double right,
  ) {}

  @override
  void startWindowMoveDrag(Offset globalPosition) {}

  @override
  void startWindowResizeDrag(Offset globalPosition, WindowEdge edge) {}

  @override
  bool titlebarNeedsDoubleClickDetector() {
    return true;
  }

  //
  // Shared feature methods.
  //

  @override
  Future<void> center() async {
    _msgSend(_nsWindow, _sel('center'));
  }

  @override
  Future<Offset> getPosition() async {
    final outX = ffi.malloc<Double>();
    final outY = ffi.malloc<Double>();
    try {
      cw_nswindow_get_frame_origin(controller.windowHandle, outX, outY);
      return Offset(outX.value, outY.value);
    } finally {
      ffi.malloc
        ..free(outX)
        ..free(outY);
    }
  }

  @override
  Future<void> setPosition(Offset position) async {
    cw_nswindow_set_frame_origin(
      controller.windowHandle,
      position.dx,
      position.dy,
    );
  }

  @override
  Future<void> setBackgroundColor(Color color) async {
    final nsColor = _msgSendId4Double(
      _cls('NSColor'),
      _sel('colorWithRed:green:blue:alpha:'),
      color.r.clamp(0.0, 1.0),
      color.g.clamp(0.0, 1.0),
      color.b.clamp(0.0, 1.0),
      color.a.clamp(0.0, 1.0),
    );
    _msgSendVoidId(_nsWindow, _sel('setBackgroundColor:'), nsColor);
  }

  @override
  Future<void> setOpacity(double opacity) async {
    _msgSendVoidBool(_nsWindow, _sel('setOpaque:'), opacity >= 1.0);
    _msgSendVoidDouble(_nsWindow, _sel('setAlphaValue:'), opacity);
  }

  @override
  Future<void> setAlwaysOnTop({required bool alwaysOnTop}) async {
    _msgSendVoidInt(
      _nsWindow,
      _sel('setLevel:'),
      alwaysOnTop ? _kNSFloatingWindowLevel : _kNSNormalWindowLevel,
    );
  }

  @override
  Future<void> setSkipTaskbar({required bool skip}) async {
    final nsApp = _msgSend(_cls('NSApplication'), _sel('sharedApplication'));
    _msgSendVoidInt(
      nsApp,
      _sel('setActivationPolicy:'),
      skip ? _kPolicyAccessory : _kPolicyRegular,
    );
  }

  @override
  Future<void> setVisible({required bool visible}) async {
    if (visible) {
      _msgSend(_nsWindow, _sel('orderFront:'));
    } else {
      _msgSend(_nsWindow, _sel('orderOut:'));
    }
  }

  //
  // macOS-only feature methods.
  //

  /// Whether the window currently has a floating-or-higher window level.
  Future<bool> isAlwaysOnTop() async {
    final level = _msgSendIntRet(_nsWindow, _sel('level'));
    return level >= _kNSFloatingWindowLevel;
  }

  /// Set whether the window has a shadow.
  Future<void> setHasShadow({required bool hasShadow}) async {
    _msgSendVoidBool(_nsWindow, _sel('setHasShadow:'), hasShadow);
  }

  /// Set whether the window can be moved by dragging its background.
  Future<void> setMovableByWindowBackground({required bool movable}) async {
    _msgSendVoidBool(
      _nsWindow,
      _sel('setMovableByWindowBackground:'),
      movable,
    );
  }

  /// Set the window's collection behavior mask.
  Future<void> setCollectionBehavior(int behavior) async {
    _msgSendVoidInt(_nsWindow, _sel('setCollectionBehavior:'), behavior);
  }

  /// Apply an `NSVisualEffectView` with the given material to the window.
  Future<void> setVibrancy(
    NSVisualEffectMaterial material, {
    NSVisualEffectBlendingMode blendingMode =
        NSVisualEffectBlendingMode.behindWindow,
    NSVisualEffectState state = NSVisualEffectState.followsWindowActiveState,
  }) async {
    cw_nswindow_apply_vibrancy(
      controller.windowHandle,
      material.value,
      blendingMode.value,
      state.value,
    );
  }
}
