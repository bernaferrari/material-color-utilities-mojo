from std.math import pow, exp, sqrt, min, max
from std.utils import StaticTuple

from lib.utils.color_utils import ColorUtils
from lib.utils.math_utils import MathUtils

comptime MathPi = 3.141592653589793238462643383279502884197169399375105820974944592307816406286208998628034825342117067982148086513282306647093844609550582231725359408128481117450284102701938521105559644622948954930381964428810975665933446128475648233786783165271201909145648566923460348610454326648213393607260249141273


struct ViewingConditions:
    var whitePoint: StaticTuple[Float64, 3]
    var adaptingLuminance: Float64
    var backgroundLstar: Float64
    var surround: Float64
    var discountingIlluminant: Bool
    var backgroundYTowhitePointY: Float64
    var aw: Float64
    var nbb: Float64
    var ncb: Float64
    var c: Float64
    var nC: Float64
    var drgbInverse: StaticTuple[Float64, 3]
    var rgbD: StaticTuple[Float64, 3]
    var fl: Float64
    var fLRoot: Float64
    var z: Float64

    def __init__(
        out self,
        whitePoint: StaticTuple[Float64, 3],
        adaptingLuminance: Float64,
        backgroundLstar: Float64,
        surround: Float64,
        discountingIlluminant: Bool,
        backgroundYTowhitePointY: Float64,
        aw: Float64,
        nbb: Float64,
        ncb: Float64,
        c: Float64,
        nC: Float64,
        drgbInverse: StaticTuple[Float64, 3],
        rgbD: StaticTuple[Float64, 3],
        fl: Float64,
        fLRoot: Float64,
        z: Float64,
    ):
        self.whitePoint = whitePoint
        self.adaptingLuminance = adaptingLuminance
        self.backgroundLstar = backgroundLstar
        self.surround = surround
        self.discountingIlluminant = discountingIlluminant
        self.backgroundYTowhitePointY = backgroundYTowhitePointY
        self.aw = aw
        self.nbb = nbb
        self.ncb = ncb
        self.c = c
        self.nC = nC
        self.drgbInverse = drgbInverse
        self.rgbD = rgbD
        self.fl = fl
        self.fLRoot = fLRoot
        self.z = z

    @staticmethod
    def make_viewing_conditions(
        whitePoint: StaticTuple[Float64, 3],
        adaptingLuminance: Float64 = -1.0,
        backgroundLstar: Float64 = 50.0,
        surround: Float64 = 2.0,
        discountingIlluminant: Bool = False,
    ) -> ViewingConditions:
        var adaptingLuminanceLocal = (
            adaptingLuminance if adaptingLuminance
            > 0 else (200 / MathPi * ColorUtils.yFromLstar(50) / 100.0)
        )
        var backgroundLstarLocal = max(0.1, backgroundLstar)

        # Transform test illuminant white in XYZ to 'cone'/'rgb' responses
        var xyz = whitePoint
        var rW = xyz[0] * 0.401288 + xyz[1] * 0.650173 + xyz[2] * -0.051461
        var gW = xyz[0] * -0.250268 + xyz[1] * 1.204414 + xyz[2] * 0.045854
        var bW = xyz[0] * -0.002079 + xyz[1] * 0.048952 + xyz[2] * 0.953127

        # Scale input surround, domain (0, 2), to CAM16 surround, domain (0.8, 1.0)

        var f = 0.8 + (surround / 10.0)
        var c = MathUtils.lerp(
            0.59, 0.69, ((f - 0.9) * 10.0)
        ) if f >= 0.9 else MathUtils.lerp(0.525, 0.59, ((f - 0.8) * 10.0))

        var expCalculation = exp((-adaptingLuminanceLocal - 42.0) / 92.0)

        # Calculate degree of adaptation to illuminant
        var d = 1.0 if discountingIlluminant else f * (
            1.0 - ((1.0 / 3.6) * expCalculation)
        )
        d = min(max(d, 0.0), 1.0)  # Limit d to [0, 1]

        var nc = f  # Chromatic induction factor
        var rgbD = StaticTuple[Float64, 3](
            d * (100.0 / rW) + 1.0 - d,
            d * (100.0 / gW) + 1.0 - d,
            d * (100.0 / bW) + 1.0 - d,
        )

        var k = 1.0 / (5.0 * adaptingLuminanceLocal + 1.0)
        var k4 = k * k * k * k
        var k4F = 1.0 - k4
        var fl = (k4 * adaptingLuminanceLocal) + (
            0.1 * k4F * k4F * pow(5.0 * adaptingLuminanceLocal, 1.0 / 3.0)
        )

        var n = (
            ColorUtils.yFromLstar(backgroundLstarLocal) / whitePoint[1]
        )  # Ratio of background relative luminance to white relative luminance
        var z = 1.48 + sqrt(n)
        var nbb = 0.725 / (n**0.2)
        var ncb = nbb

        var rgbAFactors = StaticTuple[Float64, 3](
            (fl * rgbD[0] * rW / 100.0) ** 0.42,
            (fl * rgbD[1] * gW / 100.0) ** 0.42,
            (fl * rgbD[2] * bW / 100.0) ** 0.42,
        )

        var rgbA = StaticTuple[Float64, 3](
            (400.0 * rgbAFactors[0]) / (rgbAFactors[0] + 27.13),
            (400.0 * rgbAFactors[1]) / (rgbAFactors[1] + 27.13),
            (400.0 * rgbAFactors[2]) / (rgbAFactors[2] + 27.13),
        )

        var aw = (40.0 * rgbA[0] + 20.0 * rgbA[1] + rgbA[2]) / 20.0 * nbb

        return ViewingConditions(
            whitePoint,
            adaptingLuminanceLocal,
            backgroundLstarLocal,
            surround,
            discountingIlluminant,
            n,
            aw,
            nbb,
            ncb,
            c,
            nc,
            StaticTuple[Float64, 3](0.0, 0.0, 0.0),
            rgbD,
            fl,
            pow(fl, 0.25),
            z,
        )

    @staticmethod
    def make() -> ViewingConditions:
        return ViewingConditions.make_viewing_conditions(
            ColorUtils.whitePointD65
        )

    @staticmethod
    def makeWithBackgroundLstar(backgroundLstar: Float64) -> ViewingConditions:
        return ViewingConditions.make_viewing_conditions(
            ColorUtils.whitePointD65, backgroundLstar=backgroundLstar
        )

    @staticmethod
    def srgb() -> ViewingConditions:
        return ViewingConditions.make()

    @staticmethod
    def sRgb() -> ViewingConditions:
        return ViewingConditions.srgb()

    @staticmethod
    def standard() -> ViewingConditions:
        return Self.srgb()
