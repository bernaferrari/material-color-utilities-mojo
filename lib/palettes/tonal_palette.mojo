import std.math as math
from std.utils import StaticTuple

from lib.hct.hct import Hct


struct TonalPalette(Copyable, Movable):
    comptime common_tones = StaticTuple[Int, 13](
        0, 10, 20, 30, 40, 50, 60, 70, 80, 90, 95, 99, 100
    )
    comptime common_size = 13

    var hue: Float64
    var chroma: Float64
    var key_color: Hct
    var cache: StaticTuple[Int, 13]
    var from_cache: Bool

    def __init__(
        out self,
        hue: Float64,
        chroma: Float64,
        var key_color: Hct,
        cache: StaticTuple[Int, 13],
        from_cache: Bool,
    ):
        self.hue = hue
        self.chroma = chroma
        self.key_color = key_color^
        self.cache = cache
        self.from_cache = from_cache

    @staticmethod
    def of(hue: Float64, chroma: Float64) -> TonalPalette:
        return TonalPalette(
            hue,
            chroma,
            TonalPalette.create_key_color(hue, chroma),
            StaticTuple[Int, 13](fill=0),
            False,
        )

    @staticmethod
    def from_int(argb: Int) -> TonalPalette:
        return TonalPalette.from_hct(Hct.from_int(argb))

    @staticmethod
    def fromInt(argb: Int) -> TonalPalette:
        return TonalPalette.from_int(argb)

    @staticmethod
    def from_hct(var hct: Hct) -> TonalPalette:
        return TonalPalette(
            hct.hue,
            hct.chroma,
            hct^,
            StaticTuple[Int, 13](fill=0),
            False,
        )

    @staticmethod
    def fromHct(var hct: Hct) -> TonalPalette:
        return TonalPalette.from_hct(hct^)

    @staticmethod
    def from_hue_and_chroma(hue: Float64, chroma: Float64) -> TonalPalette:
        return TonalPalette.of(hue, chroma)

    @staticmethod
    def fromHueAndChroma(hue: Float64, chroma: Float64) -> TonalPalette:
        return TonalPalette.from_hue_and_chroma(hue, chroma)

    @staticmethod
    def from_list(colors: StaticTuple[Int, 13]) -> TonalPalette:
        var best_hue = 0.0
        var best_chroma = 0.0
        for i in range(TonalPalette.common_size):
            var hct = Hct.from_int(colors[i])
            if hct.tone > 98.0:
                continue
            if hct.chroma > best_chroma:
                best_hue = hct.hue
                best_chroma = hct.chroma
        return TonalPalette(
            best_hue,
            best_chroma,
            TonalPalette.create_key_color(best_hue, best_chroma),
            colors,
            True,
        )

    @staticmethod
    def create_key_color(hue: Float64, chroma: Float64) -> Hct:
        comptime pivot_tone = 50
        comptime tone_step_size = 1
        comptime epsilon = 0.01
        comptime max_chroma_value = 200.0

        var lower_tone = 0
        var upper_tone = 100
        while lower_tone < upper_tone:
            var mid_tone = (lower_tone + upper_tone) // 2
            var mid_chroma = Hct.from_hct(
                hue, max_chroma_value, Float64(mid_tone)
            ).chroma
            var next_chroma = Hct.from_hct(
                hue, max_chroma_value, Float64(mid_tone + tone_step_size)
            ).chroma
            var is_ascending = mid_chroma < next_chroma
            var sufficient_chroma = mid_chroma >= chroma - epsilon

            if sufficient_chroma:
                if math.abs(Float64(lower_tone - pivot_tone)) < math.abs(
                    Float64(upper_tone - pivot_tone)
                ):
                    upper_tone = mid_tone
                else:
                    if lower_tone == mid_tone:
                        return Hct.from_hct(hue, chroma, Float64(lower_tone))
                    lower_tone = mid_tone
            else:
                if is_ascending:
                    lower_tone = mid_tone + tone_step_size
                else:
                    upper_tone = mid_tone

        return Hct.from_hct(hue, chroma, Float64(lower_tone))

    @staticmethod
    def _common_tone_index(tone: Int) -> Int:
        for i in range(TonalPalette.common_size):
            if tone == TonalPalette.common_tones[i]:
                return i
        return -1

    @staticmethod
    def _same_list(a: StaticTuple[Int, 13], b: StaticTuple[Int, 13]) -> Bool:
        for i in range(TonalPalette.common_size):
            if a[i] != b[i]:
                return False
        return True

    @staticmethod
    def _average_argb(argb1: Int, argb2: Int) -> Int:
        var red1 = (argb1 >> 16) & 0xFF
        var green1 = (argb1 >> 8) & 0xFF
        var blue1 = argb1 & 0xFF
        var red2 = (argb2 >> 16) & 0xFF
        var green2 = (argb2 >> 8) & 0xFF
        var blue2 = argb2 & 0xFF
        var red = Int(math.floor((Float64(red1) + Float64(red2)) / 2.0 + 0.5))
        var green = Int(
            math.floor((Float64(green1) + Float64(green2)) / 2.0 + 0.5)
        )
        var blue = Int(
            math.floor((Float64(blue1) + Float64(blue2)) / 2.0 + 0.5)
        )
        return (
            (0xFF << 24)
            | ((red & 0xFF) << 16)
            | ((green & 0xFF) << 8)
            | (blue & 0xFF)
        )

    def __eq__(self, other: TonalPalette) -> Bool:
        if not self.from_cache and not other.from_cache:
            return self.hue == other.hue and self.chroma == other.chroma
        return TonalPalette._same_list(self.as_list(), other.as_list())

    def __ne__(self, other: TonalPalette) -> Bool:
        return not self == other

    def __str__(self) -> String:
        if not self.from_cache:
            return (
                "TonalPalette.of("
                + String(self.hue)
                + ", "
                + String(self.chroma)
                + ")"
            )
        return "TonalPalette.fromList(...)"

    def get(self, tone: Int) -> Int:
        if self.from_cache:
            var index = TonalPalette._common_tone_index(tone)
            if index >= 0:
                return self.cache[index]
        if tone == 99 and Hct.is_yellow(self.hue):
            return TonalPalette._average_argb(self.get(98), self.get(100))

        return Hct.from_hct(self.hue, self.chroma, Float64(tone)).to_int()

    def tone(self, tone: Int) -> Int:
        return self.get(tone)

    def get_hct(self, tone: Float64) -> Hct:
        if self.from_cache:
            var rounded_tone = Int(round(tone))
            if math.abs(tone - Float64(rounded_tone)) < 0.000001:
                var index = TonalPalette._common_tone_index(rounded_tone)
                if index >= 0:
                    return Hct.from_int(self.cache[index])
        if tone == 99.0 and Hct.is_yellow(self.hue):
            return Hct.from_int(self.get(99))
        return Hct.from_hct(self.hue, self.chroma, tone)

    def getHct(self, tone: Float64) -> Hct:
        return self.get_hct(tone)

    def keyColor(self) -> Hct:
        return self.key_color.copy()

    def as_list(self) -> StaticTuple[Int, 13]:
        return StaticTuple[Int, 13](
            self.get(0),
            self.get(10),
            self.get(20),
            self.get(30),
            self.get(40),
            self.get(50),
            self.get(60),
            self.get(70),
            self.get(80),
            self.get(90),
            self.get(95),
            self.get(99),
            self.get(100),
        )
