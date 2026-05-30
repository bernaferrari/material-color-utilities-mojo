from std.testing import assert_equal

from lib import StringUtils as RootStringUtils
from lib.utils.string_utils import StringUtils


def main() raises:
    assert_equal("#3296FA", StringUtils.hexFromArgb(0xFF3296FA))
    assert_equal("3296FA", StringUtils.hexFromArgb(0xFF3296FA, False))
    assert_equal("#000000", StringUtils.hexFromArgb(0xFF000000))
    assert_equal("#FFFFFF", StringUtils.hexFromArgb(0xFFFFFFFF))

    assert_equal(0x3296FA, StringUtils.argbFromHex("#3296FA"))
    assert_equal(0x3296FA, StringUtils.argbFromHex("3296fa"))
    assert_equal(0xFF3296FA, StringUtils.argbFromHex("#FF3296FA"))
    assert_equal(0x3296FA, StringUtils.argbFromHex("##3296FA"))
    assert_equal(0x1234, StringUtils.argbFromHex("12#34"))
    assert_equal(-1, StringUtils.argbFromHex("#"))
    assert_equal(-1, StringUtils.argbFromHex("#32XXFA"))

    assert_equal(
        StringUtils.hexFromArgb(0xFF3296FA),
        RootStringUtils.hexFromArgb(0xFF3296FA),
    )
