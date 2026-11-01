/// 🤖 Generated wholely or partially with GPT-5; Google Antigravity
library;

import 'package:flutter/gestures.dart';

/// Action IDs assignable to universal stylus buttons.
abstract final class StylusButtonAction {
  static const none = 0;
  static const toggleEraser = 1;
  static const toggleSelect = 2;
  static const undo = 3;
  static const redo = 4;
  static const toggleHighlighter = 5;

  static const List<int> values = [
    toggleEraser,
    toggleSelect,
    undo,
    redo,
    toggleHighlighter,
    none,
  ];

  /// Human-readable label for [action].
  static String labelOf(int action) => switch (action) {
    toggleEraser => 'สลับยางลบ (Eraser)',
    toggleSelect => 'เลือกพื้นที่ (Lasso Select)',
    undo => 'ย้อนกลับ (Undo)',
    redo => 'ทำซ้ำ (Redo)',
    toggleHighlighter => 'สลับปากกา / ไฮไลท์',
    _ => 'ปิดใช้งาน (None)',
  };
}

/// Returns whether [kind] is an Android stylus input kind.
bool isStylusPointerKind(PointerDeviceKind kind) =>
    kind == PointerDeviceKind.stylus || kind == PointerDeviceKind.invertedStylus;

/// Returns whether an event should be treated as input from an active pen.
///
/// Some Android-compatible pens are exposed by the platform as a mouse or
/// trackpad while still providing a real pressure range.
bool isStylusPointer({
  required PointerDeviceKind kind,
  required double? pressure,
  required double pressureMin,
  required double pressureMax,
}) {
  if (isStylusPointerKind(kind)) return true;

  return (kind == PointerDeviceKind.mouse ||
          kind == PointerDeviceKind.trackpad) &&
      pressure != null &&
      pressureMin != pressureMax;
}

/// Returns whether a touch contact should be rejected as a palm or wide finger
/// when using a fine-tip / capacitive universal stylus.
bool isRejectedByPalmFilter({
  required PointerDeviceKind kind,
  required double radiusMajor,
  required bool palmRejectionEnabled,
  required double maxRadius,
}) {
  if (!palmRejectionEnabled) return false;
  if (kind != PointerDeviceKind.touch) return false;
  if (radiusMajor <= 0) return false;
  return radiusMajor > maxRadius;
}

/// Converts Flutter's stylus button bitmask into the editor button slot (1..4).
/// Supports standard Android styluses, Samsung S-Pen, Wacom EMR, USI, and third-party pens.
int stylusButtonFromButtons(int buttons) {
  if (buttons & kBackMouseButton != 0) return 3;
  if (buttons & kForwardMouseButton != 0) return 4;

  // Secondary / Tertiary buttons (Selection)
  if (buttons & kSecondaryStylusButton != 0) return 2;
  if (buttons & kTertiaryButton != 0) return 2;

  // Primary barrel button:
  // Samsung S-Pen and standard Android digitizers report barrel button
  // as kPrimaryStylusButton or kSecondaryButton (right-click).
  if (buttons & kPrimaryStylusButton != 0) return 1;
  if (buttons & kSecondaryButton != 0) return 1;

  return 0;
}
