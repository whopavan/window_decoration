/// DWM system backdrop types for Windows 11.
enum DWMSystemBackdropType {
  auto(0),
  none(1),
  mainWindow(2),
  transientWindow(3),
  tabbedWindow(4);

  const DWMSystemBackdropType(this.value);

  final int value;
}

/// Window corner preference for Windows 11.
enum WindowCornerPreference {
  defaultCorners(0),
  doNotRound(1),
  round(2),
  roundSmall(3);

  const WindowCornerPreference(this.value);

  final int value;
}
