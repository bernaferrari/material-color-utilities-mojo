from std.collections import List
from std.testing import assert_equal
from std.utils import StaticTuple

from lib.dynamiccolor.dynamic_color import DynamicColorRole
from lib.dynamiccolor.material_dynamic_colors import MaterialDynamicColors
from lib.hct.hct import Hct
from lib.scheme.scheme_expressive import SchemeExpressive
from lib.scheme.scheme_neutral import SchemeNeutral
from lib.scheme.scheme_tonal_spot import SchemeTonalSpot
from lib.scheme.scheme_vibrant import SchemeVibrant


def assert_2025_roles(kind: Int, platform: Int, expected: List[Int]) raises:
    var seed = Hct.from_int(0xFF6750A4)
    var scheme = SchemeTonalSpot.make(seed.copy(), False, 0.0, 2025, platform)
    if kind == 1:
        scheme = SchemeNeutral.make(seed.copy(), False, 0.0, 2025, platform)
    elif kind == 2:
        scheme = SchemeVibrant.make(seed.copy(), False, 0.0, 2025, platform)
    elif kind == 3:
        scheme = SchemeExpressive.make(seed.copy(), False, 0.0, 2025, platform)

    assert_equal(
        expected[0],
        MaterialDynamicColors.get_argb(DynamicColorRole.primary, scheme),
    )
    assert_equal(
        expected[1],
        MaterialDynamicColors.get_argb(
            DynamicColorRole.primary_container, scheme
        ),
    )
    assert_equal(
        expected[2],
        MaterialDynamicColors.get_argb(DynamicColorRole.secondary, scheme),
    )
    assert_equal(
        expected[3],
        MaterialDynamicColors.get_argb(
            DynamicColorRole.secondary_container, scheme
        ),
    )
    assert_equal(
        expected[4],
        MaterialDynamicColors.get_argb(DynamicColorRole.tertiary, scheme),
    )
    assert_equal(
        expected[5],
        MaterialDynamicColors.get_argb(
            DynamicColorRole.tertiary_container, scheme
        ),
    )
    assert_equal(
        expected[6],
        MaterialDynamicColors.get_argb(DynamicColorRole.error, scheme),
    )
    assert_equal(
        expected[7],
        MaterialDynamicColors.get_argb(
            DynamicColorRole.error_container, scheme
        ),
    )
    assert_equal(
        expected[8],
        MaterialDynamicColors.get_argb(DynamicColorRole.surface, scheme),
    )
    assert_equal(
        expected[9],
        MaterialDynamicColors.get_argb(DynamicColorRole.surface_dim, scheme),
    )
    assert_equal(
        expected[10],
        MaterialDynamicColors.get_argb(DynamicColorRole.surface_bright, scheme),
    )
    assert_equal(
        expected[11],
        MaterialDynamicColors.get_argb(
            DynamicColorRole.surface_container_highest, scheme
        ),
    )
    assert_equal(
        expected[12],
        MaterialDynamicColors.get_argb(DynamicColorRole.on_surface, scheme),
    )
    assert_equal(
        expected[13],
        MaterialDynamicColors.get_argb(
            DynamicColorRole.on_surface_variant, scheme
        ),
    )
    assert_equal(
        expected[14],
        MaterialDynamicColors.get_argb(DynamicColorRole.outline, scheme),
    )
    assert_equal(
        expected[15],
        MaterialDynamicColors.get_argb(
            DynamicColorRole.inverse_surface, scheme
        ),
    )


def values[size: Int](items: StaticTuple[Int, size]) -> List[Int]:
    var out = List[Int]()
    for i in range(size):
        out.append(items[i])
    return out^


def assert_2025_regression_roles() raises:
    var red = Hct.from_int(0xFFFF0000)
    var light = SchemeTonalSpot.make(red.copy(), False, -1.0, 2025, 0)
    assert_equal(
        0xFF3E2F2C,
        MaterialDynamicColors.get_argb(DynamicColorRole.on_background, light),
    )
    assert_equal(
        0xFFEA9D90,
        MaterialDynamicColors.get_argb(
            DynamicColorRole.primary_fixed_dim, light
        ),
    )
    assert_equal(
        0xFF451610,
        MaterialDynamicColors.get_argb(
            DynamicColorRole.on_primary_fixed, light
        ),
    )
    assert_equal(
        0xFF6B332B,
        MaterialDynamicColors.get_argb(
            DynamicColorRole.on_primary_fixed_variant, light
        ),
    )

    var dark = SchemeTonalSpot.make(red.copy(), True, -1.0, 2025, 0)
    assert_equal(
        0xFF9E665E,
        MaterialDynamicColors.get_argb(DynamicColorRole.primary_dim, dark),
    )
    assert_equal(
        0xFF8F6C67,
        MaterialDynamicColors.get_argb(DynamicColorRole.secondary_dim, dark),
    )
    assert_equal(
        0xFF926E3A,
        MaterialDynamicColors.get_argb(DynamicColorRole.tertiary_dim, dark),
    )
    assert_equal(
        0xFFC44B5F,
        MaterialDynamicColors.get_argb(DynamicColorRole.error_dim, dark),
    )

    var yellow = Hct.from_int(0xFFFFFF00)
    var tonal_yellow = SchemeTonalSpot.make(yellow.copy(), False, 0.0, 2025, 0)
    assert_equal(
        0xFFFEFCF7,
        MaterialDynamicColors.get_argb(DynamicColorRole.surface, tonal_yellow),
    )
    var vibrant_yellow = SchemeVibrant.make(yellow.copy(), True, 0.0, 2025, 0)
    assert_equal(
        0xFFFBE8A2,
        MaterialDynamicColors.get_argb(
            DynamicColorRole.on_surface, vibrant_yellow
        ),
    )

    var vibrant_red = SchemeVibrant.make(red.copy(), False, -1.0, 2025, 0)
    assert_equal(
        0xFF600000,
        MaterialDynamicColors.get_argb(
            DynamicColorRole.on_primary_fixed_variant, vibrant_red
        ),
    )


def main() raises:
    assert_2025_regression_roles()
    assert_2025_roles(
        0,
        0,
        values(
            StaticTuple[Int, 16](
                0xFF655789,
                0xFFD4C3FD,
                0xFF625C71,
                0xFFE8DEF8,
                0xFF7B5270,
                0xFFF4BFE3,
                0xFFA8364B,
                0xFFF97386,
                0xFFFDF7FE,
                0xFFDED8E4,
                0xFFFDF7FE,
                0xFFE7E0EC,
                0xFF34313A,
                0xFF615D68,
                0xFF7D7983,
                0xFF0F0D12,
            )
        ),
    )
    assert_2025_roles(
        0,
        1,
        values(
            StaticTuple[Int, 16](
                0xFFD6C5FF,
                0xFF4C3F6F,
                0xFFE8DEF8,
                0xFF4A4458,
                0xFFFFC2EC,
                0xFFD29AC2,
                0xFFFFBDC3,
                0xFF7D2938,
                0xFF000000,
                0xFFE0D6F1,
                0xFFFDF7FF,
                0xFFE8DEFA,
                0xFFEDE5F4,
                0xFFD2CBDA,
                0xFFA9A3B1,
                0xFF0F0D16,
            )
        ),
    )
    assert_2025_roles(
        1,
        0,
        values(
            StaticTuple[Int, 16](
                0xFF615D66,
                0xFFE7E0EB,
                0xFF615E62,
                0xFFE6E1E6,
                0xFF5C5D78,
                0xFFDBDAFB,
                0xFF9E3F4E,
                0xFFFF8B9A,
                0xFFFDF8F9,
                0xFFDDD9DD,
                0xFFFDF8F9,
                0xFFE6E1E4,
                0xFF333235,
                0xFF615E61,
                0xFF7D7A7D,
                0xFF0F0E0F,
            )
        ),
    )
    assert_2025_roles(
        1,
        1,
        values(
            StaticTuple[Int, 16](
                0xFFE7DFF2,
                0xFF494453,
                0xFFE6E0E9,
                0xFF48464C,
                0xFFC9CAFF,
                0xFF9C9EDC,
                0xFFFFBDC3,
                0xFF76303A,
                0xFF000000,
                0xFFDFD6EE,
                0xFFFDF7FF,
                0xFFE7DFF4,
                0xFFECE6EE,
                0xFFD2CCD4,
                0xFFA9A4AC,
                0xFF0F0D13,
            )
        ),
    )
    assert_2025_roles(
        2,
        0,
        values(
            StaticTuple[Int, 16](
                0xFF6935D9,
                0xFFAC8EFF,
                0xFF7343A9,
                0xFFE3C6FF,
                0xFF9D365D,
                0xFFFF8EB2,
                0xFFB41340,
                0xFFF74B6D,
                0xFFFDF3FF,
                0xFFE5CAFF,
                0xFFFDF3FF,
                0xFFEBD4FF,
                0xFF38264C,
                0xFF67537C,
                0xFF836E99,
                0xFF16052A,
            )
        ),
    )
    assert_2025_roles(
        2,
        1,
        values(
            StaticTuple[Int, 16](
                0xFFD6C5FF,
                0xFF50319A,
                0xFFE0C2FF,
                0xFF553B71,
                0xFFFFBCCE,
                0xFFEF779F,
                0xFFFFBDC3,
                0xFF871C34,
                0xFF000000,
                0xFFE3CBFA,
                0xFFFDF3FF,
                0xFFEBD4FF,
                0xFFF3E2FF,
                0xFFD9C7E8,
                0xFFB09FBE,
                0xFF140920,
            )
        ),
    )
    assert_2025_roles(
        3,
        0,
        values(
            StaticTuple[Int, 16](
                0xFF6850A5,
                0xFFCAB6FF,
                0xFF4D6645,
                0xFFD3F1C7,
                0xFF376B21,
                0xFFC2FFA2,
                0xFFAC3149,
                0xFFF76A80,
                0xFFFFF7FF,
                0xFFE9D1FF,
                0xFFFFF7FF,
                0xFFEFDBFF,
                0xFF3D2A51,
                0xFF6B5681,
                0xFF88729E,
                0xFF130A1E,
            )
        ),
    )
    assert_2025_roles(
        3,
        1,
        values(
            StaticTuple[Int, 16](
                0xFFD6C5FF,
                0xFF4D3C7C,
                0xFFCEEBC2,
                0xFF354D2F,
                0xFFC2FFA2,
                0xFF99D37C,
                0xFFFFBDC3,
                0xFF7D2938,
                0xFF000000,
                0xFFE6D3F5,
                0xFFFFF7FF,
                0xFFEEDCFB,
                0xFFF0E4F6,
                0xFFD6CADC,
                0xFFACA2B3,
                0xFF110C18,
            )
        ),
    )
