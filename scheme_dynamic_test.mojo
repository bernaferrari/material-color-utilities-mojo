from std.collections import List
from std.testing import assert_true
from std.utils import StaticTuple

from lib.dynamiccolor.dynamic_color import DynamicColorRole
from lib.dynamiccolor.dynamic_scheme import DynamicScheme
from lib.dynamiccolor.material_dynamic_colors import MaterialDynamicColors
from lib.hct.hct import Hct
from lib.scheme.scheme_monochrome import SchemeMonochrome


def assert_near(actual: Float64, expected: Float64, tolerance: Float64) raises:
    assert_true(actual >= expected - tolerance)
    assert_true(actual <= expected + tolerance)


def assert_role_tone(
    scheme: DynamicScheme, role: Int, expected: Float64
) raises:
    assert_near(MaterialDynamicColors.get_hct(role, scheme).tone, expected, 1.0)


def main() raises:
    var empty_hues = List[Float64]()
    var empty_rotations = List[Float64]()
    assert_near(
        DynamicScheme.get_rotated_hue_from_lists(
            Hct.from_hct(43.0, 16.0, 16.0),
            empty_hues,
            empty_rotations,
        ),
        43.0,
        1.0,
    )

    var no_rotation_hues_list = List[Float64]()
    no_rotation_hues_list.append(0.0)
    var no_rotation_values_list = List[Float64]()
    no_rotation_values_list.append(0.0)
    assert_near(
        DynamicScheme.get_rotated_hue_from_lists(
            Hct.from_hct(43.0, 16.0, 16.0),
            no_rotation_hues_list,
            no_rotation_values_list,
        ),
        43.0,
        1.0,
    )

    var no_rotation_hues = StaticTuple[Float64, 1](0.0)
    var no_rotation_values = StaticTuple[Float64, 1](0.0)
    assert_near(
        DynamicScheme.get_rotated_hue(
            Hct.from_hct(43.0, 16.0, 16.0),
            no_rotation_hues,
            no_rotation_values,
        ),
        43.0,
        1.0,
    )

    var boundary_hues = StaticTuple[Float64, 3](0.0, 42.0, 360.0)
    var boundary_rotations = StaticTuple[Float64, 3](0.0, 15.0, 0.0)
    assert_near(
        DynamicScheme.get_rotated_hue(
            Hct.from_hct(43.0, 16.0, 16.0),
            boundary_hues,
            boundary_rotations,
        ),
        58.0,
        1.0,
    )

    var boundary_hues_list = List[Float64]()
    boundary_hues_list.append(0.0)
    boundary_hues_list.append(42.0)
    boundary_hues_list.append(360.0)
    var boundary_rotations_list = List[Float64]()
    boundary_rotations_list.append(0.0)
    boundary_rotations_list.append(15.0)
    boundary_rotations_list.append(0.0)
    assert_near(
        DynamicScheme.get_rotated_hue_from_lists(
            Hct.from_hct(43.0, 16.0, 16.0),
            boundary_hues_list,
            boundary_rotations_list,
        ),
        58.0,
        1.0,
    )

    var wrapping_rotations = StaticTuple[Float64, 3](0.0, 480.0, 0.0)
    assert_near(
        DynamicScheme.get_rotated_hue(
            Hct.from_hct(43.0, 16.0, 16.0),
            boundary_hues,
            wrapping_rotations,
        ),
        163.0,
        1.0,
    )

    var mono_dark = SchemeMonochrome.make(Hct.from_int(0xFF0000FF), True, 0.0)
    assert_role_tone(mono_dark, DynamicColorRole.primary, 100.0)
    assert_role_tone(mono_dark, DynamicColorRole.on_primary, 10.0)
    assert_role_tone(mono_dark, DynamicColorRole.primary_container, 85.0)
    assert_role_tone(mono_dark, DynamicColorRole.on_primary_container, 0.0)
    assert_role_tone(mono_dark, DynamicColorRole.secondary, 80.0)
    assert_role_tone(mono_dark, DynamicColorRole.on_secondary, 10.0)
    assert_role_tone(mono_dark, DynamicColorRole.secondary_container, 30.0)
    assert_role_tone(mono_dark, DynamicColorRole.on_secondary_container, 90.0)
    assert_role_tone(mono_dark, DynamicColorRole.tertiary, 90.0)
    assert_role_tone(mono_dark, DynamicColorRole.on_tertiary, 10.0)
    assert_role_tone(mono_dark, DynamicColorRole.tertiary_container, 60.0)
    assert_role_tone(mono_dark, DynamicColorRole.on_tertiary_container, 0.0)

    var mono_light = SchemeMonochrome.make(Hct.from_int(0xFF0000FF), False, 0.0)
    assert_role_tone(mono_light, DynamicColorRole.primary, 0.0)
    assert_role_tone(mono_light, DynamicColorRole.on_primary, 90.0)
    assert_role_tone(mono_light, DynamicColorRole.primary_container, 25.0)
    assert_role_tone(mono_light, DynamicColorRole.on_primary_container, 100.0)
    assert_role_tone(mono_light, DynamicColorRole.secondary, 40.0)
    assert_role_tone(mono_light, DynamicColorRole.on_secondary, 100.0)
    assert_role_tone(mono_light, DynamicColorRole.secondary_container, 85.0)
    assert_role_tone(mono_light, DynamicColorRole.on_secondary_container, 10.0)
    assert_role_tone(mono_light, DynamicColorRole.tertiary, 25.0)
    assert_role_tone(mono_light, DynamicColorRole.on_tertiary, 90.0)
    assert_role_tone(mono_light, DynamicColorRole.tertiary_container, 49.0)
    assert_role_tone(mono_light, DynamicColorRole.on_tertiary_container, 100.0)
