/// 🤖 Generated wholely or partially with Google Antigravity
library;

import 'dart:io';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:saber/components/canvas/stylus_input.dart';
import 'package:saber/data/prefs.dart';

/// Singleton hub that manages native Android stylus button events,
/// custom Bluetooth button learning, and action resolution.
class UniversalStylusController {
  UniversalStylusController._();

  /// Shared singleton instance.
  static final instance = UniversalStylusController._();

  static const _channel = MethodChannel('com.adilhanney.saber/stylus_buttons');

  ValueChanged<int>? _onActionTriggered;
  void Function(int keyCode, String keyName, String deviceName)? _onKeyLearned;
  var _initialized = false;

  /// Registers the active editor callback that executes resolved [StylusButtonAction] IDs.
  void attachEditor(ValueChanged<int> onActionTriggered) {
    _ensureInitialized();
    _onActionTriggered = onActionTriggered;
    syncCustomKeys();
  }

  /// Detaches the editor callback when the editor is disposed.
  void detachEditor(ValueChanged<int> onActionTriggered) {
    if (_onActionTriggered == onActionTriggered) {
      _onActionTriggered = null;
    }
  }

  void _ensureInitialized() {
    if (_initialized) return;
    _initialized = true;
    _channel.setMethodCallHandler(_handleMethodCall);
  }

  Future<dynamic> _handleMethodCall(MethodCall call) async {
    switch (call.method) {
      case 'onKeyLearned':
        final args = call.arguments as Map<dynamic, dynamic>?;
        if (args == null) return;
        final keyCode = (args['keyCode'] as num?)?.toInt() ?? -1;
        final keyName = args['keyName'] as String? ?? 'KEY_$keyCode';
        final deviceName = args['deviceName'] as String? ?? 'Stylus';
        _onKeyLearned?.call(keyCode, keyName, deviceName);
        _onKeyLearned = null;
      case 'stylusCustomKey':
        final keyCode = (call.arguments as num?)?.toInt() ?? -1;
        final action = resolveCustomKeyAction(keyCode);
        if (action != StylusButtonAction.none) {
          _onActionTriggered?.call(action);
        }
      case 'stylusButton':
        final slot = (call.arguments as num?)?.toInt() ?? 0;
        final action = resolveSlotAction(slot);
        if (action != StylusButtonAction.none) {
          _onActionTriggered?.call(action);
        }
    }
  }

  /// Resolves a button slot (1..4) into a configured [StylusButtonAction].
  int resolveSlotAction(int slot) => switch (slot) {
    1 => stows.stylusButton1Action.value,
    2 => stows.stylusButton2Action.value,
    3 => stows.stylusButton3Action.value,
    4 => StylusButtonAction.redo,
    _ => StylusButtonAction.none,
  };

  /// Resolves a learned Android [keyCode] into a configured [StylusButtonAction].
  int resolveCustomKeyAction(int keyCode) {
    if (keyCode <= 0) return StylusButtonAction.none;
    if (keyCode == stows.customStylusButton1Key.value) {
      return stows.stylusButton1Action.value;
    }
    if (keyCode == stows.customStylusButton2Key.value) {
      return stows.stylusButton2Action.value;
    }
    if (keyCode == stows.customStylusButton3Key.value) {
      return stows.stylusButton3Action.value;
    }
    return StylusButtonAction.none;
  }

  /// Synchronizes user-learned keycodes with the native Android activity.
  Future<void> syncCustomKeys() async {
    if (!Platform.isAndroid) return;
    _ensureInitialized();
    final keys = <int>[
      if (stows.customStylusButton1Key.value > 0)
        stows.customStylusButton1Key.value,
      if (stows.customStylusButton2Key.value > 0)
        stows.customStylusButton2Key.value,
      if (stows.customStylusButton3Key.value > 0)
        stows.customStylusButton3Key.value,
    ];
    try {
      await _channel.invokeMethod<void>('setCustomKeys', keys);
    } on PlatformException {
      // Ignore when running in unit tests or unsupported hosts.
    }
  }

  /// Starts listening for the next hardware/Bluetooth pen button press.
  Future<void> startLearning(
    void Function(int keyCode, String keyName, String deviceName) onLearned,
  ) async {
    _ensureInitialized();
    _onKeyLearned = onLearned;
    if (!Platform.isAndroid) return;
    try {
      await _channel.invokeMethod<void>('setLearningMode', true);
    } on PlatformException {
      // Ignore on unsupported hosts.
    }
  }

  /// Cancels active button learning mode.
  Future<void> cancelLearning() async {
    _onKeyLearned = null;
    if (!Platform.isAndroid) return;
    try {
      await _channel.invokeMethod<void>('setLearningMode', false);
    } on PlatformException {
      // Ignore on unsupported hosts.
    }
  }
}

/// Draggable floating quick-action toolbar for universal styluses without side buttons.
class FloatingStylusQuickPill extends StatefulWidget {
  /// Creates a [FloatingStylusQuickPill].
  const FloatingStylusQuickPill({
    super.key,
    required this.isEraserActive,
    required this.isSelectActive,
    required this.onTriggerAction,
  });

  /// Whether the eraser tool is currently active.
  final bool isEraserActive;

  /// Whether the lasso selection tool is currently active.
  final bool isSelectActive;

  /// Callback invoked with a [StylusButtonAction] constant.
  final ValueChanged<int> onTriggerAction;

  @override
  State<FloatingStylusQuickPill> createState() =>
      _FloatingStylusQuickPillState();
}

class _FloatingStylusQuickPillState extends State<FloatingStylusQuickPill> {
  var _offset = const Offset(16, 120);

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final screenSize = MediaQuery.sizeOf(context);

    return Positioned(
      left: _offset.dx.clamp(8.0, (screenSize.width - 72).clamp(8.0, 2000.0)),
      top: _offset.dy.clamp(8.0, (screenSize.height - 240).clamp(8.0, 2000.0)),
      child: GestureDetector(
        onPanUpdate: (details) {
          setState(() {
            _offset += details.delta;
          });
        },
        child: Material(
          elevation: 4,
          borderRadius: BorderRadius.circular(28),
          color: colorScheme.surfaceContainerHigh.withValues(alpha: 0.92),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 4),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.drag_indicator,
                  size: 16,
                  color: colorScheme.onSurfaceVariant,
                ),
                const SizedBox(height: 2),
                IconButton(
                  visualDensity: VisualDensity.compact,
                  tooltip: 'สลับยางลบ (Eraser)',
                  isSelected: widget.isEraserActive,
                  style: IconButton.styleFrom(
                    backgroundColor: widget.isEraserActive
                        ? colorScheme.primaryContainer
                        : null,
                  ),
                  icon: Icon(
                    Icons.auto_fix_normal,
                    size: 20,
                    color: widget.isEraserActive
                        ? colorScheme.onPrimaryContainer
                        : colorScheme.onSurface,
                  ),
                  onPressed: () =>
                      widget.onTriggerAction(StylusButtonAction.toggleEraser),
                ),
                IconButton(
                  visualDensity: VisualDensity.compact,
                  tooltip: 'เลือกพื้นที่ (Select)',
                  isSelected: widget.isSelectActive,
                  style: IconButton.styleFrom(
                    backgroundColor: widget.isSelectActive
                        ? colorScheme.primaryContainer
                        : null,
                  ),
                  icon: Icon(
                    Icons.gesture,
                    size: 20,
                    color: widget.isSelectActive
                        ? colorScheme.onPrimaryContainer
                        : colorScheme.onSurface,
                  ),
                  onPressed: () =>
                      widget.onTriggerAction(StylusButtonAction.toggleSelect),
                ),
                IconButton(
                  visualDensity: VisualDensity.compact,
                  tooltip: 'ย้อนกลับ (Undo)',
                  icon: Icon(
                    Icons.undo,
                    size: 20,
                    color: colorScheme.onSurface,
                  ),
                  onPressed: () =>
                      widget.onTriggerAction(StylusButtonAction.undo),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Bottom sheet allowing the user to configure the Universal Pen Engine,
/// calibrate palm/finger contact size rejection, and learn Bluetooth pen buttons.
class UniversalStylusSheet extends StatefulWidget {
  /// Creates a [UniversalStylusSheet].
  const UniversalStylusSheet({super.key});

  @override
  State<UniversalStylusSheet> createState() => _UniversalStylusSheetState();
}

class _UniversalStylusSheetState extends State<UniversalStylusSheet> {
  var _learningSlot = 0;
  var _lastLearnedInfo = '';
  var _lastDetectedKind = '';
  var _lastDetectedRadius = 0.0;

  @override
  void dispose() {
    UniversalStylusController.instance.cancelLearning();
    super.dispose();
  }

  void _startLearningSlot(int slot) {
    setState(() {
      _learningSlot = slot;
      _lastLearnedInfo = 'กำลังรอรับสัญญาณ... กดปุ่มที่ด้ามปากกาได้เลย';
    });
    UniversalStylusController.instance.startLearning((
      keyCode,
      keyName,
      deviceName,
    ) {
      if (!mounted) return;
      if (slot == 1) stows.customStylusButton1Key.value = keyCode;
      if (slot == 2) stows.customStylusButton2Key.value = keyCode;
      if (slot == 3) stows.customStylusButton3Key.value = keyCode;
      UniversalStylusController.instance.syncCustomKeys();
      setState(() {
        _learningSlot = 0;
        _lastLearnedInfo = 'บันทึกสำเร็จ: $keyName ($deviceName)';
      });
    });
  }

  void _clearSlotKey(int slot) {
    if (slot == 1) stows.customStylusButton1Key.value = -1;
    if (slot == 2) stows.customStylusButton2Key.value = -1;
    if (slot == 3) stows.customStylusButton3Key.value = -1;
    UniversalStylusController.instance.syncCustomKeys();
    setState(() {});
  }

  void _handleCalibrationPointer(PointerEvent event) {
    final isActivePen = isStylusPointer(
      kind: event.kind,
      pressure: event.pressure,
      pressureMin: event.pressureMin,
      pressureMax: event.pressureMax,
    );
    setState(() {
      _lastDetectedKind = isActivePen
          ? 'Active Stylus (${event.kind.name})'
          : 'Universal / Touch (${event.kind.name})';
      _lastDetectedRadius = event.radiusMajor;
    });
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final radiusThreshold = stows.universalPalmRejectionRadius.value;
    final isSampleRejected =
        _lastDetectedKind.startsWith('Universal') &&
        isRejectedByPalmFilter(
          kind: PointerDeviceKind.touch,
          radiusMajor: _lastDetectedRadius,
          palmRejectionEnabled: stows.universalPalmRejectionEnabled.value,
          maxRadius: radiusThreshold,
        );

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Icon(Icons.draw_outlined, color: colorScheme.primary, size: 24),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  'ระบบปากกาครอบจักรวาล (Universal Pen Engine)',
                  style: textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            'รองรับทั้ง Active Stylus (S-Pen, Redmi, USI, Wacom) และปากกา Universal ทุกชนิด (หัวทองแดง, หัวจาน, หัวยาง, ปากกา Bluetooth)',
            style: textTheme.bodySmall?.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
          ),
          const Divider(height: 24),
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            title: const Text('เปิดโหมด Universal Pen อัตโนมัติ'),
            subtitle: const Text(
              'เขียนได้ทันทีทั้งปากกาชิปและปากกาทั่วไปโดยไม่ต้องสลับโหมดเอง',
            ),
            value: stows.universalPenMode.value,
            onChanged: (val) => setState(() {
              stows.universalPenMode.value = val;
            }),
          ),
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            title: const Text('แสดงปุ่มลัดลอยข้างจอ (สำหรับปากกาไร้ปุ่มกด)'),
            subtitle: const Text(
              'แถบลอยลากย้ายได้สำหรับกด ยางลบ / เลือกพื้นที่ / Undo อย่างรวดเร็ว',
            ),
            value: stows.floatingStylusQuickBall.value,
            onChanged: (val) => setState(() {
              stows.floatingStylusQuickBall.value = val;
            }),
          ),
          const Divider(height: 24),
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            title: const Text('ระบบตัดอุ้งมือ & แยกขนาดหัวปากกาอัจฉริยะ'),
            subtitle: const Text(
              'กรองสัมผัสที่มีพื้นที่กว้าง (อุ้งมือหรือนิ้ว) ไม่ให้เขียนเลอะกระดาษ',
            ),
            value: stows.universalPalmRejectionEnabled.value,
            onChanged: (val) => setState(() {
              stows.universalPalmRejectionEnabled.value = val;
            }),
          ),
          if (stows.universalPalmRejectionEnabled.value) ...[
            const SizedBox(height: 8),
            Listener(
              onPointerDown: _handleCalibrationPointer,
              onPointerMove: _handleCalibrationPointer,
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: colorScheme.outlineVariant),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'แตะที่นี่ด้วย "หัวปากกา" เทียบกับ "นิ้ว/อุ้งมือ" เพื่อวัดขนาด:',
                      style: textTheme.labelMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      _lastDetectedKind.isEmpty
                          ? 'ยังไม่ได้แตะทดสอบ'
                          : '$_lastDetectedKind • ขนาดสัมผัส: ${_lastDetectedRadius.toStringAsFixed(1)} px '
                                '(${isSampleRejected ? "ตัดทิ้ง / เลื่อนหน้าจอ" : "อนุญาตให้เขียน"})',
                      style: textTheme.bodySmall?.copyWith(
                        color: isSampleRejected
                            ? colorScheme.error
                            : colorScheme.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: Text(
                    'ขนาดหัวปากกาสูงสุด: ${radiusThreshold.toStringAsFixed(0)} px',
                    style: textTheme.bodySmall,
                  ),
                ),
                Wrap(
                  spacing: 6,
                  children: [
                    ActionChip(
                      label: const Text('หัวเล็ก 9px'),
                      onPressed: () => setState(() {
                        stows.universalPalmRejectionRadius.value = 9.0;
                      }),
                    ),
                    ActionChip(
                      label: const Text('มาตรฐาน 18px'),
                      onPressed: () => setState(() {
                        stows.universalPalmRejectionRadius.value = 18.0;
                      }),
                    ),
                  ],
                ),
              ],
            ),
            Slider(
              min: 4.0,
              max: 40.0,
              divisions: 36,
              value: radiusThreshold.clamp(4.0, 40.0),
              label: '${radiusThreshold.toStringAsFixed(0)} px',
              onChanged: (val) => setState(() {
                stows.universalPalmRejectionRadius.value = val;
              }),
            ),
          ],
          const Divider(height: 24),
          Text(
            'ตั้งค่าและจำปุ่มกดปากกา Bluetooth / Stylus ทุกยี่ห้อ',
            style: textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 4),
          Text(
            'ใช้งานได้ทันทีกับ S-Pen, Redmi Pen, Surface/MPP และรีโมท Bluetooth หรือกด "จำปุ่ม" เพื่อผูกปุ่มของปากการุ่นใดก็ได้',
            style: textTheme.bodySmall?.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
          ),
          if (_lastLearnedInfo.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              _lastLearnedInfo,
              style: textTheme.bodySmall?.copyWith(
                color: colorScheme.primary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
          const SizedBox(height: 12),
          _buildButtonSlotRow(
            slot: 1,
            title: 'ปุ่มปากกาที่ 1',
            customKey: stows.customStylusButton1Key.value,
            actionValue: stows.stylusButton1Action.value,
            onActionChanged: (val) => setState(() {
              stows.stylusButton1Action.value = val;
            }),
          ),
          const SizedBox(height: 10),
          _buildButtonSlotRow(
            slot: 2,
            title: 'ปุ่มปากกาที่ 2',
            customKey: stows.customStylusButton2Key.value,
            actionValue: stows.stylusButton2Action.value,
            onActionChanged: (val) => setState(() {
              stows.stylusButton2Action.value = val;
            }),
          ),
          const SizedBox(height: 10),
          _buildButtonSlotRow(
            slot: 3,
            title: 'ปุ่มปากกาที่ 3',
            customKey: stows.customStylusButton3Key.value,
            actionValue: stows.stylusButton3Action.value,
            onActionChanged: (val) => setState(() {
              stows.stylusButton3Action.value = val;
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildButtonSlotRow({
    required int slot,
    required String title,
    required int customKey,
    required int actionValue,
    required ValueChanged<int> onActionChanged,
  }) {
    final isLearning = _learningSlot == slot;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                customKey > 0 ? '$title (รหัสปุ่ม #$customKey)' : '$title (ค่าสากล)',
                style: const TextStyle(fontWeight: FontWeight.w500),
              ),
            ),
            if (Platform.isAndroid) ...[
              OutlinedButton.icon(
                icon: Icon(
                  isLearning ? Icons.sensors : Icons.bluetooth_searching,
                  size: 16,
                ),
                label: Text(isLearning ? 'กดปุ่มเลย...' : 'จำปุ่ม'),
                onPressed: isLearning
                    ? () {
                        UniversalStylusController.instance.cancelLearning();
                        setState(() {
                          _learningSlot = 0;
                          _lastLearnedInfo = '';
                        });
                      }
                    : () => _startLearningSlot(slot),
              ),
              if (customKey > 0)
                IconButton(
                  tooltip: 'ล้างค่าปุ่มที่จำไว้',
                  icon: const Icon(Icons.clear, size: 18),
                  onPressed: () => _clearSlotKey(slot),
                ),
            ],
          ],
        ),
        const SizedBox(height: 4),
        DropdownButtonFormField<int>(
          initialValue: StylusButtonAction.values.contains(actionValue)
              ? actionValue
              : StylusButtonAction.toggleEraser,
          decoration: const InputDecoration(
            isDense: true,
            border: OutlineInputBorder(),
            contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          ),
          items: StylusButtonAction.values
              .map(
                (act) => DropdownMenuItem<int>(
                  value: act,
                  child: Text(StylusButtonAction.labelOf(act)),
                ),
              )
              .toList(),
          onChanged: (val) {
            if (val != null) onActionChanged(val);
          },
        ),
      ],
    );
  }
}
