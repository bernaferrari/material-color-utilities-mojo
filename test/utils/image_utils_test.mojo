from std.collections import List
from std.testing import assert_equal, TestSuite

from lib.utils.image_utils import ImageUtils


def test_image_utils() raises:
    var bytes = List[Int]()
    # Transparent pixels are ignored.
    bytes.append(0)
    bytes.append(0)
    bytes.append(255)
    bytes.append(128)

    # Opaque red dominates.
    for _ in range(8):
        bytes.append(255)
        bytes.append(0)
        bytes.append(0)
        bytes.append(255)

    bytes.append(0)
    bytes.append(255)
    bytes.append(0)
    bytes.append(255)

    assert_equal(0xFFFF0000, ImageUtils.source_color_from_image_bytes(bytes))


def main() raises:
    TestSuite.discover_tests[__functions_in_module()]().run()
