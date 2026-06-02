from std.testing import assert_equal, TestSuite
from lib.blend.blend import Blend
from lib.utils.string_utils import StringUtils


def test_blend() raises:
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

    var t7 = Blend.harmonize(green, blue)
    var rs7 = assert_equal("00FC94", StringUtils.hexFromArgb(t7, False))

    var t8 = Blend.harmonize(green, red)
    var rs8 = assert_equal("B1F000", StringUtils.hexFromArgb(t8, False))

    var t9 = Blend.harmonize(green, yellow)
    var rs9 = assert_equal("B1F000", StringUtils.hexFromArgb(t9, False))

    var t10 = Blend.harmonize(yellow, blue)
    var rs10 = assert_equal("EBFFBA", StringUtils.hexFromArgb(t10, False))

    var t11 = Blend.harmonize(yellow, green)
    var rs11 = assert_equal("EBFFBA", StringUtils.hexFromArgb(t11, False))

    var t12 = Blend.harmonize(yellow, red)
    var rs12 = assert_equal("FFF6E3", StringUtils.hexFromArgb(t12, False))


def main() raises:
    TestSuite.discover_tests[__functions_in_module()]().run()
