import std.math as math
from std.utils import StaticTuple

from lib.hct.cam16 import Cam16
from lib.palettes.tonal_palette import TonalPalette


struct CorePalette(Copyable, Movable):
    comptime size = 5

    var primary: TonalPalette
    var secondary: TonalPalette
    var tertiary: TonalPalette
    var neutral: TonalPalette
    var neutral_variant: TonalPalette
    var error: TonalPalette

    def __init__(
        out self,
        var primary: TonalPalette,
        var secondary: TonalPalette,
        var tertiary: TonalPalette,
        var neutral: TonalPalette,
        var neutral_variant: TonalPalette,
        var error: TonalPalette,
    ):
        self.primary = primary^
        self.secondary = secondary^
        self.tertiary = tertiary^
        self.neutral = neutral^
        self.neutral_variant = neutral_variant^
        self.error = error^

    @staticmethod
    def of(argb: Int) -> CorePalette:
        var cam = Cam16.from_int(argb)
        return CorePalette._from_hue_and_chroma(cam.hue, cam.chroma)

    @staticmethod
    def _from_hue_and_chroma(hue: Float64, chroma: Float64) -> CorePalette:
        return CorePalette(
            TonalPalette.of(hue, math.max(48.0, chroma)),
            TonalPalette.of(hue, 16.0),
            TonalPalette.of(hue + 60.0, 24.0),
            TonalPalette.of(hue, 4.0),
            TonalPalette.of(hue, 8.0),
            TonalPalette.of(25.0, 84.0),
        )

    @staticmethod
    def content_of(argb: Int) -> CorePalette:
        var cam = Cam16.from_int(argb)
        return CorePalette._content_from_hue_and_chroma(cam.hue, cam.chroma)

    @staticmethod
    def _content_from_hue_and_chroma(
        hue: Float64, chroma: Float64
    ) -> CorePalette:
        return CorePalette(
            TonalPalette.of(hue, chroma),
            TonalPalette.of(hue, chroma / 3.0),
            TonalPalette.of(hue + 60.0, chroma / 2.0),
            TonalPalette.of(hue, math.min(chroma / 12.0, 4.0)),
            TonalPalette.of(hue, math.min(chroma / 6.0, 8.0)),
            TonalPalette.of(25.0, 84.0),
        )

    @staticmethod
    def from_list(colors: StaticTuple[Int, 65]) -> CorePalette:
        return CorePalette(
            TonalPalette.from_list(CorePalette._partition(colors, 0)),
            TonalPalette.from_list(CorePalette._partition(colors, 1)),
            TonalPalette.from_list(CorePalette._partition(colors, 2)),
            TonalPalette.from_list(CorePalette._partition(colors, 3)),
            TonalPalette.from_list(CorePalette._partition(colors, 4)),
            TonalPalette.of(25.0, 84.0),
        )

    @staticmethod
    def _partition(
        colors: StaticTuple[Int, 65], partition_number: Int
    ) -> StaticTuple[Int, 13]:
        var start = partition_number * TonalPalette.common_size
        return StaticTuple[Int, 13](
            colors[start],
            colors[start + 1],
            colors[start + 2],
            colors[start + 3],
            colors[start + 4],
            colors[start + 5],
            colors[start + 6],
            colors[start + 7],
            colors[start + 8],
            colors[start + 9],
            colors[start + 10],
            colors[start + 11],
            colors[start + 12],
        )

    def __eq__(self, other: CorePalette) -> Bool:
        return (
            self.primary == other.primary
            and self.secondary == other.secondary
            and self.tertiary == other.tertiary
            and self.neutral == other.neutral
            and self.neutral_variant == other.neutral_variant
            and self.error == other.error
        )

    def __ne__(self, other: CorePalette) -> Bool:
        return not self == other

    def __str__(self) -> String:
        return (
            "primary: "
            + self.primary.__str__()
            + "\nsecondary: "
            + self.secondary.__str__()
            + "\ntertiary: "
            + self.tertiary.__str__()
            + "\nneutral: "
            + self.neutral.__str__()
            + "\nneutralVariant: "
            + self.neutral_variant.__str__()
            + "\nerror: "
            + self.error.__str__()
            + "\n"
        )

    def as_list(self) -> StaticTuple[Int, 65]:
        var p = self.primary.as_list()
        var s = self.secondary.as_list()
        var t = self.tertiary.as_list()
        var n = self.neutral.as_list()
        var nv = self.neutral_variant.as_list()
        return StaticTuple[Int, 65](
            p[0],
            p[1],
            p[2],
            p[3],
            p[4],
            p[5],
            p[6],
            p[7],
            p[8],
            p[9],
            p[10],
            p[11],
            p[12],
            s[0],
            s[1],
            s[2],
            s[3],
            s[4],
            s[5],
            s[6],
            s[7],
            s[8],
            s[9],
            s[10],
            s[11],
            s[12],
            t[0],
            t[1],
            t[2],
            t[3],
            t[4],
            t[5],
            t[6],
            t[7],
            t[8],
            t[9],
            t[10],
            t[11],
            t[12],
            n[0],
            n[1],
            n[2],
            n[3],
            n[4],
            n[5],
            n[6],
            n[7],
            n[8],
            n[9],
            n[10],
            n[11],
            n[12],
            nv[0],
            nv[1],
            nv[2],
            nv[3],
            nv[4],
            nv[5],
            nv[6],
            nv[7],
            nv[8],
            nv[9],
            nv[10],
            nv[11],
            nv[12],
        )
