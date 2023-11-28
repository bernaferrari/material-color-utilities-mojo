from math import pow, exp, sqrt, min, max

from lib.utils.color_utils import ColorUtils
from lib.utils.math_utils import MathUtils

alias MathPi = 3.141592653589793238462643383279502884197169399375105820974944592307816406286208998628034825342117067982148086513282306647093844609550582231725359408128481117450284102701938521105559644622948954930381964428810975665933446128475648233786783165271201909145648566923460348610454326648213393607260249141273


struct ViewingConditions:
    var whitePoint: StaticTuple[3, Float32]
    var adaptingLuminance: Float32
    var backgroundLstar: Float32
    var surround: Float32
    var discountingIlluminant: Bool
    var backgroundYTowhitePointY: Float32
    var aw: Float32
    var nbb: Float32
    var ncb: Float32
    var c: Float32
    var nC: Float32
    var drgbInverse: StaticTuple[3, Float32]
    var rgbD: StaticTuple[3, Float32]
    var fl: Float32
    var fLRoot: Float32
    var z: Float32

    fn __init__(
        inout self,
        whitePoint: StaticTuple[3, Float32],
        adaptingLuminance: Float32,
        backgroundLstar: Float32,
        surround: Float32,
        discountingIlluminant: Bool,
        backgroundYTowhitePointY: Float32,
        aw: Float32,
        nbb: Float32,
        ncb: Float32,
        c: Float32,
        nC: Float32,
        drgbInverse: StaticTuple[3, Float32],
        rgbD: StaticTuple[3, Float32],
        fl: Float32,
        fLRoot: Float32,
        z: Float32,
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
    fn make_viewing_conditions(
        whitePoint: StaticTuple[3, Float32],
        adaptingLuminance: Float32 = -1.0,
        backgroundLstar: Float32 = 50.0,
        surround: Float32 = 2.0,
        discountingIlluminant: Bool = False,
    ) -> ViewingConditions:
        let adaptingLuminanceLocal = adaptingLuminance if adaptingLuminance > 0 else (
            200 / MathPi * ColorUtils.yFromLstar(50) / 100.0
        )
        let backgroundLstarLocal = max(0.1, backgroundLstar)

        # Transform test illuminant white in XYZ to 'cone'/'rgb' responses
        let xyz = whitePoint
        let rW = xyz[0] * 0.401288 + xyz[1] * 0.650173 + xyz[2] * -0.051461
        let gW = xyz[0] * -0.250268 + xyz[1] * 1.204414 + xyz[2] * 0.045854
        let bW = xyz[0] * -0.002079 + xyz[1] * 0.048952 + xyz[2] * 0.953127

        # Scale input surround, domain (0, 2), to CAM16 surround, domain (0.8, 1.0)

        let updatedSurround = surround if surround > 0 and surround < 2 else max(
            2, min(0, surround)
        )

        let f = 0.8 + (surround / 10.0)
        let c = MathUtils.lerp(
            0.59, 0.69, ((f - 0.9) * 10.0)
        ) if f >= 0.9 else MathUtils.lerp(0.525, 0.59, ((f - 0.8) * 10.0))

        let expCalculation = exp[DType.float32, 1](
            (-adaptingLuminanceLocal - 42.0) / 92.0
        )

        # Calculate degree of adaptation to illuminant
        var d = 1.0 if discountingIlluminant else f * (
            1.0 - ((1.0 / 3.6) * expCalculation)
        )
        d = min(max(d, 0.0), 1.0)  # Limit d to [0, 1]

        let nc = f  # Chromatic induction factor
        let n = ColorUtils.yFromLstar(backgroundLstarLocal) / whitePoint[
            1
        ]  # Ratio of background relative luminance to white relative luminance
        let z = 1.48 + sqrt(n)
        let rgbD = StaticTuple[3, Float32](
            d * (100.0 / rW) + 1.0 - d,
            d * (100.0 / gW) + 1.0 - d,
            d * (100.0 / bW) + 1.0 - d,
        )

        let fl = 1.0  # assuming a function fl(x) is defined and used here
        let nbb = 0.725 / (n**0.2)
        let ncb = nbb

        let rgbAFactors = StaticTuple[3, Float32](
            (fl * rgbD[0] * rW / 100.0) ** 0.42,
            (fl * rgbD[1] * gW / 100.0) ** 0.42,
            (fl * rgbD[2] * bW / 100.0) ** 0.42,
        )

        let rgbA = StaticTuple[3, Float32](
            (400.0 * rgbAFactors[0]) / (rgbAFactors[0] + 27.13),
            (400.0 * rgbAFactors[1]) / (rgbAFactors[1] + 27.13),
            (400.0 * rgbAFactors[2]) / (rgbAFactors[2] + 27.13),
        )

        let aw = (40.0 * rgbA[0] + 20.0 * rgbA[1] + rgbA[2]) / 20.0 * nbb

        return ViewingConditions(
            whitePoint,
            adaptingLuminance,
            backgroundLstar,
            surround,
            discountingIlluminant,
            n,
            aw,
            nbb,
            ncb,
            c,
            nc,
            StaticTuple[3, Float32](0.0, 0.0, 0.0),
            rgbD,
            fl,
            fl**0.25,
            z,
        )

    @staticmethod
    fn srgb() -> ViewingConditions:
        return ViewingConditions.make_viewing_conditions(ColorUtils.whitePointD65)

    @staticmethod
    fn standard() -> ViewingConditions:
        return Self.srgb()
