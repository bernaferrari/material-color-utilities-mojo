from std.testing import assert_equal, TestSuite
from std.collections import List

from lib.dislike.dislike_analyzer import DislikeAnalyzer
from lib.hct.hct import Hct


def assert_liked(color: Int) raises:
    assert_equal(False, DislikeAnalyzer.is_disliked(Hct.from_int(color)))


def assert_disliked(color: Int) raises:
    assert_equal(True, DislikeAnalyzer.is_disliked(Hct.from_int(color)))


def test_dislike_analyzer() raises:
    var monk_skin_tone_scale_colors = List[Int]()
    monk_skin_tone_scale_colors.append(0xFFF6EDE4)
    monk_skin_tone_scale_colors.append(0xFFF3E7DB)
    monk_skin_tone_scale_colors.append(0xFFF7EAD0)
    monk_skin_tone_scale_colors.append(0xFFEADABA)
    monk_skin_tone_scale_colors.append(0xFFD7BD96)
    monk_skin_tone_scale_colors.append(0xFFA07E56)
    monk_skin_tone_scale_colors.append(0xFF825C43)
    monk_skin_tone_scale_colors.append(0xFF604134)
    monk_skin_tone_scale_colors.append(0xFF3A312A)
    monk_skin_tone_scale_colors.append(0xFF292420)
    for color in monk_skin_tone_scale_colors:
        assert_liked(color)

    var unlikable = List[Int]()
    unlikable.append(0xFF95884B)
    unlikable.append(0xFF716B40)
    unlikable.append(0xFFB08E00)
    unlikable.append(0xFF4C4308)
    unlikable.append(0xFF464521)
    for color in unlikable:
        assert_disliked(color)
        var hct = Hct.from_int(color)
        var fixed = DislikeAnalyzer.fix_if_disliked(hct)
        assert_equal(False, DislikeAnalyzer.is_disliked(fixed))

    var tone_67 = Hct.from_hct(100.0, 50.0, 67.0)
    assert_equal(False, DislikeAnalyzer.is_disliked(tone_67))
    assert_equal(
        tone_67.to_int(), DislikeAnalyzer.fix_if_disliked(tone_67).to_int()
    )


def main() raises:
    TestSuite.discover_tests[__functions_in_module()]().run()
