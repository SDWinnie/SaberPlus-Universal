/// 🤖 Generated wholely or partially with GPT-5; Google Antigravity
library;

import 'package:flutter/gestures.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:saber/components/canvas/stylus_input.dart';

void main() {
  test('accepts stylus and inverted stylus pointer kinds', () {
    expect(isStylusPointerKind(PointerDeviceKind.stylus), isTrue);
    expect(isStylusPointerKind(PointerDeviceKind.invertedStylus), isTrue);
  });

  test('accepts Android pen events reported as mouse when pressure is present', () {
    expect(
      isStylusPointer(
        kind: PointerDeviceKind.mouse,
        pressure: 0.5,
        pressureMin: 0,
        pressureMax: 1,
      ),
      isTrue,
    );
  });

  test('does not classify touch pressure as a stylus', () {
    expect(
      isStylusPointer(
        kind: PointerDeviceKind.touch,
        pressure: 0.5,
        pressureMin: 0,
        pressureMax: 1,
      ),
      isFalse,
    );
  });

  test('maps Android and universal stylus button bitmasks', () {
    expect(stylusButtonFromButtons(kPrimaryStylusButton), 1);
    expect(stylusButtonFromButtons(kSecondaryButton), 1);
    expect(stylusButtonFromButtons(kSecondaryStylusButton), 2);
    expect(stylusButtonFromButtons(kTertiaryButton), 2);
    expect(stylusButtonFromButtons(kBackMouseButton), 3);
    expect(stylusButtonFromButtons(kForwardMouseButton), 4);
    expect(stylusButtonFromButtons(0), 0);
  });

  test('rejects wide palm/finger contacts while accepting fine capacitive stylus tips', () {
    expect(
      isRejectedByPalmFilter(
        kind: PointerDeviceKind.touch,
        radiusMajor: 3.2,
        palmRejectionEnabled: true,
        maxRadius: 6.5,
      ),
      isFalse,
    );
    expect(
      isRejectedByPalmFilter(
        kind: PointerDeviceKind.touch,
        radiusMajor: 12.0,
        palmRejectionEnabled: true,
        maxRadius: 6.5,
      ),
      isTrue,
    );
    expect(
      isRejectedByPalmFilter(
        kind: PointerDeviceKind.stylus,
        radiusMajor: 20.0,
        palmRejectionEnabled: true,
        maxRadius: 6.5,
      ),
      isFalse,
    );
  });
}
