import std.math as math
from lib.hct.cam16 import Cam16
from lib.hct.hct import Hct
from lib.utils import ColorUtils
from lib.utils.math_utils import MathUtils


struct Blend:
    @staticmethod
    def harmonize(design_color: Int, source_color: Int) -> Int:
        var from_hct = Hct.from_int(design_color)
        var to_hct = Hct.from_int(source_color)
        var difference_degrees = MathUtils.differenceDegrees(
            from_hct.hue, to_hct.hue
        )
        var rotation_degrees = math.min(difference_degrees * 0.5, 15.0)
        var output_hue = MathUtils.sanitizeDegreesDouble(
            from_hct.hue
            + rotation_degrees
            * MathUtils.rotationDirection(from_hct.hue, to_hct.hue)
        )
        var intReturnValue = Hct.to_int2(
            Hct.from_hct(output_hue, from_hct.chroma, from_hct.tone)
        )
        return intReturnValue

    @staticmethod
    def hct_hue(from_color: Int, to_color: Int, amount: Float64) -> Int:
        var ucs = Blend.cam16_ucs(from_color, to_color, amount)
        var ucs_cam = Cam16.from_int(ucs)
        var from_cam = Cam16.from_int(from_color)
        var blended = Hct.from_hct(
            ucs_cam.hue, from_cam.chroma, ColorUtils.lstarFromArgb(from_color)
        )
        return blended.to_int()

    @staticmethod
    def cam16_ucs(from_color: Int, to_color: Int, amount: Float64) -> Int:
        var from_cam = Cam16.from_int(from_color)
        var to_cam = Cam16.from_int(to_color)
        var from_j = from_cam.jstar
        var from_a = from_cam.astar
        var from_b = from_cam.bstar
        var to_j = to_cam.jstar
        var to_a = to_cam.astar
        var to_b = to_cam.bstar
        var jstar = from_j + (to_j - from_j) * amount
        var astar = from_a + (to_a - from_a) * amount
        var bstar = from_b + (to_b - from_b) * amount

        var returnValue = Cam16.fromUcs(jstar, astar, bstar)
        return returnValue.to_int()
