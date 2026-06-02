from std.collections import Dict, List
from std.testing import assert_equal, TestSuite

from lib.score.score import Score


def assert_ranked(
    actual: List[Int], expected0: Int, expected1: Int = -1, expected2: Int = -1
) raises:
    assert_equal(expected0, actual[0])
    if expected1 != -1:
        assert_equal(expected1, actual[1])
    if expected2 != -1:
        assert_equal(expected2, actual[2])


def test_score() raises:
    var chroma_population = Dict[Int, Int]()
    chroma_population[0xFF000000] = 1
    chroma_population[0xFFFFFFFF] = 1
    chroma_population[0xFF0000FF] = 1
    var chroma_ranked = Score.score(chroma_population)
    assert_equal(1, len(chroma_ranked))
    assert_equal(0xFF0000FF, chroma_ranked[0])

    var equal_population = Dict[Int, Int]()
    equal_population[0xFFFF0000] = 1
    equal_population[0xFF00FF00] = 1
    equal_population[0xFF0000FF] = 1
    var equal_ranked = Score.score(equal_population)
    assert_equal(3, len(equal_ranked))
    assert_equal(0xFFFF0000, equal_ranked[0])
    assert_equal(0xFF00FF00, equal_ranked[1])
    assert_equal(0xFF0000FF, equal_ranked[2])

    var fallback_population = Dict[Int, Int]()
    fallback_population[0xFF000000] = 1
    var fallback_ranked = Score.score(fallback_population)
    assert_equal(1, len(fallback_ranked))
    assert_equal(0xFF4285F4, fallback_ranked[0])

    var dedupe_population = Dict[Int, Int]()
    dedupe_population[0xFF008772] = 1
    dedupe_population[0xFF318477] = 1
    var dedupe_ranked = Score.score(dedupe_population)
    assert_equal(1, len(dedupe_ranked))
    assert_equal(0xFF008772, dedupe_ranked[0])

    var generated = Dict[Int, Int]()
    generated[0xFFD33881] = 14
    generated[0xFF3205CC] = 77
    generated[0xFF0B48CF] = 36
    generated[0xFFA08F5D] = 81
    var generated_ranked = Score.score(generated, desired=4, filter=True)
    assert_equal(3, len(generated_ranked))
    assert_equal(0xFF3205CC, generated_ranked[0])
    assert_equal(0xFFA08F5D, generated_ranked[1])
    assert_equal(0xFFD33881, generated_ranked[2])

    var distance_population = Dict[Int, Int]()
    distance_population[0xFF008772] = 1
    distance_population[0xFF008587] = 1
    distance_population[0xFF007EBC] = 1
    var distance_ranked = Score.score(distance_population, desired=2)
    assert_equal(2, len(distance_ranked))
    assert_ranked(distance_ranked, 0xFF007EBC, 0xFF008772)

    var generated_one = Dict[Int, Int]()
    generated_one[0xFF7EA16D] = 67
    generated_one[0xFFD8CCAE] = 67
    generated_one[0xFF835C0D] = 49
    var ranked_one = Score.score(
        generated_one,
        desired=3,
        fallback_color_argb=0xFF8D3819,
        filter=False,
    )
    assert_equal(3, len(ranked_one))
    assert_ranked(ranked_one, 0xFF7EA16D, 0xFFD8CCAE, 0xFF835C0D)

    var generated_three = Dict[Int, Int]()
    generated_three[0xFFBE94A6] = 23
    generated_three[0xFFC33FD7] = 42
    generated_three[0xFF899F36] = 90
    generated_three[0xFF94C574] = 82
    var ranked_three = Score.score(
        generated_three,
        desired=3,
        fallback_color_argb=0xFFAA79A4,
        filter=True,
    )
    assert_equal(3, len(ranked_three))
    assert_ranked(ranked_three, 0xFF94C574, 0xFFC33FD7, 0xFFBE94A6)

    var generated_four = Dict[Int, Int]()
    generated_four[0xFFDF241C] = 85
    generated_four[0xFF685859] = 44
    generated_four[0xFFD06D5F] = 34
    generated_four[0xFF561C54] = 27
    generated_four[0xFF713090] = 88
    var ranked_four = Score.score(
        generated_four,
        desired=5,
        fallback_color_argb=0xFF58C19C,
        filter=False,
    )
    assert_equal(2, len(ranked_four))
    assert_ranked(ranked_four, 0xFFDF241C, 0xFF561C54)

    var generated_five = Dict[Int, Int]()
    generated_five[0xFFBE66F8] = 41
    generated_five[0xFF4BBDA9] = 88
    generated_five[0xFF80F6F9] = 44
    generated_five[0xFFAB8017] = 43
    generated_five[0xFFE89307] = 65
    var ranked_five = Score.score(
        generated_five,
        desired=3,
        fallback_color_argb=0xFF916691,
        filter=False,
    )
    assert_equal(3, len(ranked_five))
    assert_ranked(ranked_five, 0xFFAB8017, 0xFF4BBDA9, 0xFFBE66F8)

    var generated_six = Dict[Int, Int]()
    generated_six[0xFF18EA8F] = 93
    generated_six[0xFF327593] = 18
    generated_six[0xFF066A18] = 53
    generated_six[0xFFFA8A23] = 74
    generated_six[0xFF04CA1F] = 62
    var ranked_six = Score.score(
        generated_six,
        desired=2,
        fallback_color_argb=0xFF4C377A,
        filter=False,
    )
    assert_equal(2, len(ranked_six))
    assert_ranked(ranked_six, 0xFF18EA8F, 0xFFFA8A23)

    var generated_seven = Dict[Int, Int]()
    generated_seven[0xFF2E05ED] = 23
    generated_seven[0xFF153E55] = 90
    generated_seven[0xFF9AB220] = 23
    generated_seven[0xFF153379] = 66
    generated_seven[0xFF68BCC3] = 81
    var ranked_seven = Score.score(
        generated_seven,
        desired=2,
        fallback_color_argb=0xFFF588DC,
        filter=True,
    )
    assert_equal(2, len(ranked_seven))
    assert_ranked(ranked_seven, 0xFF2E05ED, 0xFF9AB220)

    var generated_eight = Dict[Int, Int]()
    generated_eight[0xFF816EC5] = 24
    generated_eight[0xFF6DCB94] = 19
    generated_eight[0xFF3CAE91] = 98
    generated_eight[0xFF5B542F] = 25
    var ranked_eight = Score.score(
        generated_eight,
        desired=1,
        fallback_color_argb=0xFF84B0FD,
        filter=False,
    )
    assert_equal(1, len(ranked_eight))
    assert_ranked(ranked_eight, 0xFF3CAE91)

    var generated_nine = Dict[Int, Int]()
    generated_nine[0xFF206F86] = 52
    generated_nine[0xFF4A620D] = 96
    generated_nine[0xFFF51401] = 85
    generated_nine[0xFF2B8EBF] = 3
    generated_nine[0xFF277766] = 59
    var ranked_nine = Score.score(
        generated_nine,
        desired=3,
        fallback_color_argb=0xFF02B415,
        filter=True,
    )
    assert_equal(3, len(ranked_nine))
    assert_ranked(ranked_nine, 0xFFF51401, 0xFF4A620D, 0xFF2B8EBF)

    var generated_ten = Dict[Int, Int]()
    generated_ten[0xFF8B1D99] = 54
    generated_ten[0xFF27EFFE] = 43
    generated_ten[0xFF6F558D] = 2
    generated_ten[0xFF77FDF2] = 78
    var ranked_ten = Score.score(
        generated_ten,
        desired=4,
        fallback_color_argb=0xFF5E7A10,
        filter=True,
    )
    assert_equal(3, len(ranked_ten))
    assert_ranked(ranked_ten, 0xFF27EFFE, 0xFF8B1D99, 0xFF6F558D)


def main() raises:
    TestSuite.discover_tests[__functions_in_module()]().run()
