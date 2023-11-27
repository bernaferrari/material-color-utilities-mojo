from testing import assert_true

import 'package:material_color_utilities/blend/blend.dart';
import 'package:test/test.dart';

import './utils/color_matcher.dart';

const red = 0xffff0000;
const blue = 0xff0000ff;
const green = 0xff00ff00;
const yellow = 0xffffff00;
void main() {
  group('Harmonize', () {
    test('redToBlue', () {
      final answer = Blend.harmonize(red, blue);
      expect(answer, isColor(0xffFB0057));
    });

    test('redToGreen', () {
      final answer = Blend.harmonize(red, green);
      expect(answer, isColor(0xffD85600));
    });

    test('redToYellow', () {
      final answer = Blend.harmonize(red, yellow);
      expect(answer, isColor(0xffD85600));
    });

    test('blueToGreen', () {
      final answer = Blend.harmonize(blue, green);
      expect(answer, isColor(0xff0047A3));
    });

    test('blueToRed', () {
      final answer = Blend.harmonize(blue, red);
      expect(answer, isColor(0xff5700DC));
    });

    test('blueToYellow', () {
      final answer = Blend.harmonize(blue, yellow);
      expect(answer, isColor(0xff0047A3));
    });

    test('greenToBlue', () {
      final answer = Blend.harmonize(green, blue);
      expect(answer, isColor(0xff00FC94));
    });

    test('greenToRed', () {
      final answer = Blend.harmonize(green, red);
      expect(answer, isColor(0xffB1F000));
    });

    test('greenToYellow', () {
      final answer = Blend.harmonize(green, yellow);
      expect(answer, isColor(0xffB1F000));
    });

    test('yellowToBlue', () {
      final answer = Blend.harmonize(yellow, blue);
      expect(answer, isColor(0xffEBFFBA));
    });

    test('yellowToGreen', () {
      final answer = Blend.harmonize(yellow, green);
      expect(answer, isColor(0xffEBFFBA));
    });

    test('yellowToRed', () {
      final answer = Blend.harmonize(yellow, red);
      expect(answer, isColor(0xffFFF6E3));
    });
  });
}
