import math
from lib.hct.cam16 import Cam16
from lib.hct.hct import Hct
from lib.utils import ColorUtils
from lib.utils.math_utils import (
    sanitizeDegreesDouble,
    differenceDegrees,
    rotationDirection,
)


struct Blend:
    @staticmethod
    fn harmonize(design_color: Int, source_color: Int) -> Int:
        let from_hct = Hct.from_int(design_color)
        let to_hct = Hct.from_int(source_color)
        let difference_degrees = differenceDegrees(from_hct.hue, to_hct.hue)
        let rotation_degrees = math.min(difference_degrees * 0.5, 15.0)
        let output_hue = sanitizeDegreesDouble(
            from_hct.hue
            + rotation_degrees * rotationDirection(from_hct.hue, to_hct.hue)
        )
        let intReturnValue = Hct.to_int2(
            Hct.from_hct(output_hue, from_hct.chroma, from_hct.tone)
        )
        return intReturnValue

    @staticmethod
    fn hct_hue(from_color: Int, to_color: Int, amount: Float32) -> Int:
        let ucs = Blend.cam16_ucs(from_color, to_color, amount)
        let ucs_cam = Cam16.from_int(ucs)
        let from_cam = Cam16.from_int(from_color)
        let blended = Hct.from_hct(
            ucs_cam.hue, from_cam.chroma, ColorUtils.lstarFromArgb(from_color)
        )
        return blended.to_int()

    @staticmethod
    fn cam16_ucs(from_color: Int, to_color: Int, amount: Float32) -> Int:
        let from_cam = Cam16.from_int(from_color)
        let to_cam = Cam16.from_int(to_color)
        let from_j = from_cam.jstar
        let from_a = from_cam.astar
        let from_b = from_cam.bstar
        let to_j = to_cam.jstar
        let to_a = to_cam.astar
        let to_b = to_cam.bstar
        let jstar = from_j + (to_j - from_j) * amount
        let astar = from_a + (to_a - from_a) * amount
        let bstar = from_b + (to_b - from_b) * amount

        # TODO find a way to do Cam16.fromUCS(...).to_int() in one line
        let returnValue = Cam16.fromUcs(jstar, astar, bstar)
        return returnValue.to_int()
