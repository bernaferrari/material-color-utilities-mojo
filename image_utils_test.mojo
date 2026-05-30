from std.collections import List
from std.testing import assert_equal

from lib.utils.image_utils import ImageUtils


def main() raises:
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
