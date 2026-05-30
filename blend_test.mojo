from std.testing import assert_equal
from lib.blend.blend import Blend
from lib.utils.string_utils import StringUtils


def main() raises:
    comptime red: Int = 0xFFFF0000
    comptime blue: Int = 0xFF0000FF
    comptime green: Int = 0xFF00FF00
    comptime yellow: Int = 0xFFFFFF00

    var t1 = Blend.harmonize(red, blue)
    var rs1 = assert_equal("FB0057", StringUtils.hexFromArgb(t1, False))

    var t2 = Blend.harmonize(red, green)
    var rs2 = assert_equal("D85600", StringUtils.hexFromArgb(t2, False))

    var t3 = Blend.harmonize(red, yellow)
    var rs3 = assert_equal("D85600", StringUtils.hexFromArgb(t3, False))

    var t4 = Blend.harmonize(blue, green)
    var rs4 = assert_equal("0047A3", StringUtils.hexFromArgb(t4, False))

    var t5 = Blend.harmonize(blue, red)
    var rs5 = assert_equal("5700DC", StringUtils.hexFromArgb(t5, False))

    var t6 = Blend.harmonize(blue, yellow)
    var rs6 = assert_equal("0047A3", StringUtils.hexFromArgb(t6, False))
