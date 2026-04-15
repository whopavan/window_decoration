/// NSVisualEffectMaterial constants for macOS vibrancy effects.
enum NSVisualEffectMaterial {
  appearanceBased(0),
  titlebar(3),
  selection(4),
  menu(5),
  popover(6),
  sidebar(7),
  headerView(10),
  sheet(11),
  windowBackground(12),
  hudWindow(13),
  fullScreenUI(15),
  toolTip(17),
  contentBackground(18),
  underWindowBackground(21),
  underPageBackground(22);

  const NSVisualEffectMaterial(this.value);

  final int value;
}

/// NSVisualEffectBlendingMode constants.
enum NSVisualEffectBlendingMode {
  behindWindow(0),
  withinWindow(1);

  const NSVisualEffectBlendingMode(this.value);

  final int value;
}

/// NSVisualEffectState constants.
enum NSVisualEffectState {
  active(1),
  inactive(2),
  followsWindowActiveState(0);

  const NSVisualEffectState(this.value);

  final int value;
}
