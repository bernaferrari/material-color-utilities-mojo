from lib.utils.color_utils import ColorUtils
from lib.hct.cam16 import Cam16
from lib.hct.viewing_conditions import ViewingConditions
from lib.hct.hct_solver import HctSolver
from std.math import round


struct Hct(Copyable, Movable):
    var hue: Float64
    var chroma: Float64
    var tone: Float64
    var argb: Int

    def __init__(
        out self, hue: Float64, chroma: Float64, tone: Float64, argb: Int
    ):
        self.hue = hue
        self.chroma = chroma
        self.tone = tone
        self.argb = argb

    @staticmethod
    def from_hct(hue: Float64, chroma: Float64, tone: Float64) -> Hct:
        var argb = HctSolver.solve_to_int(hue, chroma, tone)
        return Self.from_int(argb)

    @staticmethod
    def from_int(argb: Int) -> Hct:
        var cam16 = Cam16.from_int(argb)
        var hue = cam16.hue
        var chroma = cam16.chroma
        var tone = ColorUtils.lstarFromArgb(argb)
        return Hct(hue, chroma, tone, argb)

    @staticmethod
    def fromInt(argb: Int) -> Hct:
        return Hct.from_int(argb)

    @staticmethod
    def is_blue(hue: Float64) -> Bool:
        return hue >= 250.0 and hue < 270.0

    @staticmethod
    def isBlue(hue: Float64) -> Bool:
        return Hct.is_blue(hue)

    @staticmethod
    def is_yellow(hue: Float64) -> Bool:
        return hue >= 105.0 and hue < 125.0

    @staticmethod
    def isYellow(hue: Float64) -> Bool:
        return Hct.is_yellow(hue)

    @staticmethod
    def is_cyan(hue: Float64) -> Bool:
        return hue >= 170.0 and hue < 207.0

    @staticmethod
    def isCyan(hue: Float64) -> Bool:
        return Hct.is_cyan(hue)

    def __eq__(self, other: Hct) -> Bool:
        return self.argb == other.argb

    def __ne__(self, other: Hct) -> Bool:
        return self.argb != other.argb

    def __str__(self) -> String:
        return (
            "H"
            + String(Int(round(self.hue)))
            + " C"
            + String(Int(round(self.chroma)))
            + " T"
            + String(Int(round(self.tone)))
        )

    def to_int(self) -> Int:
        return self.argb

    def toInt(self) -> Int:
        return self.to_int()

    @staticmethod
    def to_int2(hct: Hct) -> Int:
        return hct.argb

    def get_hue(self) -> Float64:
        return self.hue

    def get_tone(self) -> Float64:
        return self.tone

    def set_hue(mut self, new_hue: Float64):
        self.argb = HctSolver.solve_to_int(new_hue, self.chroma, self.tone)
        var cam16 = Cam16.from_int(self.argb)
        self.hue = cam16.hue
        self.chroma = cam16.chroma
        self.tone = ColorUtils.lstarFromArgb(self.argb)

    def get_chroma(self) -> Float64:
        return self.chroma

    def set_chroma(mut self, new_chroma: Float64):
        self.argb = HctSolver.solve_to_int(self.hue, new_chroma, self.tone)
        var cam16 = Cam16.from_int(self.argb)
        self.hue = cam16.hue
        self.chroma = cam16.chroma
        self.tone = ColorUtils.lstarFromArgb(self.argb)

    def set_tone(mut self, new_tone: Float64):
        self.argb = HctSolver.solve_to_int(self.hue, self.chroma, new_tone)
        var cam16 = Cam16.from_int(self.argb)
        self.hue = cam16.hue
        self.chroma = cam16.chroma
        self.tone = ColorUtils.lstarFromArgb(self.argb)

    def in_viewing_conditions(self, vc: ViewingConditions) -> Hct:
        var hct_to_int = self.to_int()
        var cam16 = Cam16.from_int(hct_to_int)

        var viewed_in_vc = cam16.xyz_in_viewing_conditions(vc)
        var recast_in_vc = cam16.from_xyz_in_viewing_conditions(
            viewed_in_vc[0],
            viewed_in_vc[1],
            viewed_in_vc[2],
            ViewingConditions.make_viewing_conditions(ColorUtils.whitePointD65),
        )
        return Self.from_hct(
            recast_in_vc.hue,
            recast_in_vc.chroma,
            ColorUtils.lstarFromY(viewed_in_vc[1]),
        )

    def inViewingConditions(self, vc: ViewingConditions) -> Hct:
        return self.in_viewing_conditions(vc)
