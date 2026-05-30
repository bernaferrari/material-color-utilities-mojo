from std.utils import StaticTuple

from lib.utils.color_utils import ColorUtils


struct PointProviderLab:
    @staticmethod
    def from_int(argb: Int) -> StaticTuple[Float64, 3]:
        return ColorUtils.labFromArgb(argb)

    @staticmethod
    def to_int(point: StaticTuple[Float64, 3]) -> Int:
        return ColorUtils.argbFromLab(point[0], point[1], point[2])

    @staticmethod
    def distance(
        one: StaticTuple[Float64, 3], two: StaticTuple[Float64, 3]
    ) -> Float64:
        var d_l = one[0] - two[0]
        var d_a = one[1] - two[1]
        var d_b = one[2] - two[2]
        return d_l * d_l + d_a * d_a + d_b * d_b
