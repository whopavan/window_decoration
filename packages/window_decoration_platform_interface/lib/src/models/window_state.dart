/// Represents the current state of a window.
///
/// Values match Win32 `SIZE_*` constants from `WM_SIZE` wParam:
/// - `SIZE_RESTORED` = 0
/// - `SIZE_MINIMIZED` = 1
/// - `SIZE_MAXIMIZED` = 2
enum WindowState {
  /// The window has been restored to its normal size.
  restored(0),

  /// The window has been minimized.
  minimized(1),

  /// The window has been maximized.
  maximized(2);

  const WindowState(this.nativeValue);

  /// The native Win32 SIZE_* value.
  final int nativeValue;

  /// Creates a [WindowState] from a native Win32 SIZE_* value.
  ///
  /// Returns `null` for unrecognized values.
  static WindowState? fromNativeValue(int value) {
    for (final state in values) {
      if (state.nativeValue == value) return state;
    }
    return null;
  }
}
