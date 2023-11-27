from testing import assert_equal, assert_true
from lib.utils.color_utils import ColorUtils
from lib.blend.blend import Blend
from lib.hct.hct import Hct
from lib.utils.string_utils import StringUtils


fn main():
    # Simple demonstration of HCT.
    let color = Hct.from_int(0xFF4285F4)
    print("Hue:", color.hue)
    print("Chroma:", color.chroma)
    print("Tone:", color.tone)

    alias red: Int = 0xFFFF0000
    alias blue: Int = 0xFF0000FF
    alias green: Int = 0xFF00FF00
    alias yellow: Int = 0xFFFFFF00

    let t1 = Blend.harmonize(red, blue)
    let rs1 = assert_equal("FB0056", StringUtils.hexFromArgb(t1))

    let t2 = Blend.harmonize(red, green)
    let rs2 = assert_equal("D85600", StringUtils.hexFromArgb(t2))

    let t3 = Blend.harmonize(red, yellow)
    let rs3 = assert_equal("D85600", StringUtils.hexFromArgb(t3))

    let t4 = Blend.harmonize(blue, green)
    let rs4 = assert_equal("0048A3", StringUtils.hexFromArgb(t4))

    let t5 = Blend.harmonize(blue, red)
    let rs5 = assert_equal("5700DC", StringUtils.hexFromArgb(t5))

    let t6 = Blend.harmonize(blue, yellow)
    let rs6 = assert_equal("0048A3", StringUtils.hexFromArgb(t6))
