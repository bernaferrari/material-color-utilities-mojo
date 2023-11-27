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
    let rs1 = assert_equal(t1, 4293411840)
    print("t1 is", StringUtils.hexFromArgb(t1))
    
