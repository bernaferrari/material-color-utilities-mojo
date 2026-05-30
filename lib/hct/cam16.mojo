import std.math as math
from std.utils import StaticTuple
from lib.utils.color_utils import ColorUtils
from lib.utils.math_utils import MathUtils
from lib.hct.viewing_conditions import ViewingConditions

comptime MathPi = 3.141592653589793238462643383279502884197169399375105820974944592307816406286208998628034825342117067982148086513282306647093844609550582231725359408128481117450284102701938521105559644622948954930381964428810975665933446128475648233786783165271201909145648566923460348610454326648213393607260249141273


struct Cam16:
    var hue: Float64
    var chroma: Float64
    var j: Float64
    var q: Float64
    var m: Float64
    var s: Float64
    var jstar: Float64
    var astar: Float64
    var bstar: Float64

    def __init__(
        out self,
        hue: Float64,
        chroma: Float64,
        j: Float64,
        q: Float64,
        m: Float64,
        s: Float64,
        jstar: Float64,
        astar: Float64,
        bstar: Float64,
    ):
        self.hue = hue
        self.chroma = chroma
        self.j = j
        self.q = q
        self.m = m
        self.s = s
        self.jstar = jstar
        self.astar = astar
        self.bstar = bstar

    def distance(cam16_1: Cam16, cam16_2: Cam16) -> Float64:
        var dJ: Float64 = cam16_1.jstar - cam16_2.jstar
        var dA: Float64 = cam16_1.astar - cam16_2.astar
        var dB: Float64 = cam16_1.bstar - cam16_2.bstar
        var dEPrime: Float64 = math.sqrt(dJ * dJ + dA * dA + dB * dB)
        var dE: Float64 = 1.41 * float_pow(dEPrime, 0.63)
        return dE

    @staticmethod
    def from_int(argb: Int) -> Cam16:
        return Self.from_int_in_viewing_conditions(
            argb, ViewingConditions.srgb()
        )

    @staticmethod
    def fromInt(argb: Int) -> Cam16:
        return Self.from_int(argb)

    @staticmethod
    def from_int_in_viewing_conditions(
        argb: Int, viewing_conditions: ViewingConditions
    ) -> Cam16:
        var xyz = ColorUtils.xyzFromArgb(argb)
        var x: Float64 = xyz[0]
        var y: Float64 = xyz[1]
        var z: Float64 = xyz[2]
        return Self.from_xyz_in_viewing_conditions(x, y, z, viewing_conditions)

    @staticmethod
    def fromIntInViewingConditions(
        argb: Int, viewing_conditions: ViewingConditions
    ) -> Cam16:
        return Self.from_int_in_viewing_conditions(argb, viewing_conditions)

    @staticmethod
    def from_xyz_in_viewing_conditions(
        x: Float64,
        y: Float64,
        z: Float64,
        viewing_conditions: ViewingConditions,
    ) -> Cam16:
        var rC: Float64 = 0.401288 * x + 0.650173 * y - 0.051461 * z
        var gC: Float64 = -0.250268 * x + 1.204414 * y + 0.045854 * z
        var bC: Float64 = -0.002079 * x + 0.048952 * y + 0.953127 * z

        var rD: Float64 = viewing_conditions.rgbD[0] * rC
        var gD: Float64 = viewing_conditions.rgbD[1] * gC
        var bD: Float64 = viewing_conditions.rgbD[2] * bC

        var rAF = float_pow(viewing_conditions.fl * math.abs(rD) / 100.0, 0.42)
        var gAF = float_pow(viewing_conditions.fl * math.abs(gD) / 100.0, 0.42)
        var bAF = float_pow(viewing_conditions.fl * math.abs(bD) / 100.0, 0.42)

        var rA = MathUtils.signum(rD) * 400.0 * rAF / (rAF + 27.13)
        var gA = MathUtils.signum(gD) * 400.0 * gAF / (gAF + 27.13)
        var bA = MathUtils.signum(bD) * 400.0 * bAF / (bAF + 27.13)

        # redness-greenness
        var a = (11.0 * rA + -12.0 * gA + bA) / 11.0
        # yellowness-blueness
        var b = (rA + gA - 2.0 * bA) / 9.0

        # auxiliary components
        var u = (20.0 * rA + 20.0 * gA + 21.0 * bA) / 20.0
        var p2 = (40.0 * rA + 20.0 * gA + bA) / 20.0

        var atan2_b_a: Float64 = math.atan2(b, a)
        var atan_degrees: Float64 = atan2_b_a * 180.0 / MathPi
        var hue: Float64 = (
            atan_degrees if atan_degrees >= 0 else atan_degrees + 360.0
        )
        var hue_radians: Float64 = hue * MathPi / 180.0

        var ac: Float64 = p2 * viewing_conditions.nbb
        var j: Float64 = 100.0 * math.pow(
            ac / viewing_conditions.aw,
            viewing_conditions.c * viewing_conditions.z,
        )
        var q: Float64 = (
            (4.0 / viewing_conditions.c)
            * math.sqrt(j / 100.0)
            * (viewing_conditions.aw + 4.0)
            * viewing_conditions.fLRoot
        )

        var hue_prime: Float64 = hue if hue >= 20.14 else hue + 360
        var e_hue = (1.0 / 4.0) * (
            math.cos(hue_prime * MathPi / 180.0 + 2.0) + 3.8
        )
        var p1: Float64 = (
            50000.0
            / 13.0
            * e_hue
            * viewing_conditions.nC
            * viewing_conditions.ncb
        )
        var t: Float64 = p1 * math.sqrt(a * a + b * b) / (u + 0.305)

        var alpha = float_pow(t, 0.9) * float_pow(
            1.64 - float_pow(0.29, viewing_conditions.backgroundYTowhitePointY),
            0.73,
        )

        var c: Float64 = alpha * math.sqrt(j / 100.0)
        var m: Float64 = c * viewing_conditions.fLRoot
        var s: Float64 = 50.0 * math.sqrt(
            (alpha * viewing_conditions.c) / (viewing_conditions.aw + 4.0)
        )
        var jstar: Float64 = (1.0 + 100.0 * 0.007) * j / (1.0 + 0.007 * j)
        var mstar: Float64 = math.log(1.0 + 0.0228 * m) / 0.0228
        var astar: Float64 = mstar * math.cos(hue_radians)
        var bstar: Float64 = mstar * math.sin(hue_radians)

        return Cam16(hue, c, j, q, m, s, jstar, astar, bstar)

    @staticmethod
    def fromXyzInViewingConditions(
        x: Float64,
        y: Float64,
        z: Float64,
        viewing_conditions: ViewingConditions,
    ) -> Cam16:
        return Self.from_xyz_in_viewing_conditions(x, y, z, viewing_conditions)

    @staticmethod
    def fromJch(j: Float64, c: Float64, h: Float64) -> Cam16:
        return Self.fromJchInViewingConditions(
            j, c, h, ViewingConditions.srgb()
        )

    @staticmethod
    def fromJchInViewingConditions(
        J: Float64, C: Float64, h: Float64, viewingConditions: ViewingConditions
    ) -> Cam16:
        var Q = (
            (4.0 / viewingConditions.c)
            * math.sqrt(J / 100.0)
            * (viewingConditions.aw + 4.0)
            * viewingConditions.fLRoot
        )
        var M = C * viewingConditions.fLRoot
        var alpha = C / math.sqrt(J / 100.0)
        var s = 50.0 * math.sqrt(
            (alpha * viewingConditions.c) / (viewingConditions.aw + 4.0)
        )

        var hueRadians = h * MathPi / 180
        var jstar = (1.0 + 100.0 * 0.007) * J / (1.0 + 0.007 * J)
        var mstar = 1.0 / 0.0228 * math.log(1.0 + 0.0228 * M)
        var astar = mstar * math.cos(hueRadians)
        var bstar = mstar * math.sin(hueRadians)
        return Cam16(h, C, J, Q, M, s, jstar, astar, bstar)

    # Create a CAM16 color from CAM16-UCS coordinates [jstar], [astar], [bstar].
    # assuming the color was viewed in default viewing conditions.
    @staticmethod
    def fromUcs(jstar: Float64, astar: Float64, bstar: Float64) -> Cam16:
        return Self.fromUcsInViewingConditions(
            jstar, astar, bstar, ViewingConditions.standard()
        )

    # Create a CAM16 color from CAM16-UCS coordinates [jstar], [astar], [bstar].
    # in [viewingConditions].
    @staticmethod
    def fromUcsInViewingConditions(
        jstar: Float64,
        astar: Float64,
        bstar: Float64,
        viewingConditions: ViewingConditions,
    ) -> Cam16:
        var a = astar
        var b = bstar
        var m = math.sqrt(a * a + b * b)
        var M = (math.exp(m * 0.0228) - 1.0) / 0.0228
        var c = M / viewingConditions.fLRoot
        var h = math.atan2(b, a) * (180.0 / MathPi)
        if h < 0.0:
            h += 360.0
        var j = jstar / (1 - (jstar - 100) * 0.007)

        return Self.fromJchInViewingConditions(j, c, h, viewingConditions)

    def to_int(self) -> Int:
        return self.viewed(ViewingConditions.srgb())

    def toInt(self) -> Int:
        return self.to_int()

    def viewed(self, viewing_conditions: ViewingConditions) -> Int:
        var xyz: StaticTuple[Float64, 3] = Self.xyz_in_viewing_conditions(
            self, viewing_conditions
        )
        return ColorUtils.argbFromXyz(xyz[0], xyz[1], xyz[2])

    def xyz_in_viewing_conditions(
        cam16: Cam16, viewing_conditions: ViewingConditions
    ) -> StaticTuple[Float64, 3]:
        var alpha: Float64 = (
            cam16.chroma
            / math.sqrt(cam16.j / 100.0) if (
                cam16.chroma != 0.0 and cam16.j != 0.0
            ) else 0.0
        )

        var t: Float64 = float_pow(
            alpha
            / float_pow(
                1.64
                - float_pow(0.29, viewing_conditions.backgroundYTowhitePointY),
                0.73,
            ),
            1.0 / 0.9,
        )
        var h_rad: Float64 = cam16.hue * MathPi / 180.0
        var e_hue = (math.cos(h_rad + 2.0) + 3.8) / 4.0
        var ac: Float64 = viewing_conditions.aw * math.pow(
            cam16.j / 100.0, 1.0 / (viewing_conditions.c * viewing_conditions.z)
        )
        var p1: Float64 = (
            e_hue
            * (50000.0 / 13.0)
            * viewing_conditions.nC
            * viewing_conditions.ncb
        )
        var p2: Float64 = ac / viewing_conditions.nbb
        var h_sin: Float64 = math.sin(h_rad)
        var h_cos: Float64 = math.cos(h_rad)
        var gamma: Float64 = (
            23.0
            * (p2 + 0.305)
            * t
            / (23.0 * p1 + 11 * t * h_cos + 108.0 * t * h_sin)
        )
        var a: Float64 = gamma * h_cos
        var b: Float64 = gamma * h_sin
        var r_a: Float64 = (460.0 * p2 + 451.0 * a + 288.0 * b) / 1403.0
        var g_a: Float64 = (460.0 * p2 - 891.0 * a - 261.0 * b) / 1403.0
        var b_a: Float64 = (460.0 * p2 - 220.0 * a - 6300.0 * b) / 1403.0
        var r_c_base: Float64 = math.max(
            0.0, (27.13 * math.abs(r_a)) / (400.0 - math.abs(r_a))
        )
        var r_c: Float64 = (
            MathUtils.signum(r_a)
            * (100.0 / viewing_conditions.fl)
            * float_pow(r_c_base, 1.0 / 0.42)
        )
        var g_c_base: Float64 = math.max(
            0.0, (27.13 * math.abs(g_a)) / (400.0 - math.abs(g_a))
        )
        var g_c: Float64 = (
            MathUtils.signum(g_a)
            * (100.0 / viewing_conditions.fl)
            * float_pow(g_c_base, 1.0 / 0.42)
        )
        var b_c_base: Float64 = math.max(
            0.0, (27.13 * math.abs(b_a)) / (400.0 - math.abs(b_a))
        )
        var b_c: Float64 = (
            MathUtils.signum(b_a)
            * (100.0 / viewing_conditions.fl)
            * float_pow(b_c_base, 1.0 / 0.42)
        )

        # Optimized into SIMD:
        var r_f: Float64 = r_c / viewing_conditions.rgbD[0]
        var g_f: Float64 = g_c / viewing_conditions.rgbD[1]
        var b_f: Float64 = b_c / viewing_conditions.rgbD[2]

        #   var simd_f = SIMD[DType.float64, 3](r_c, g_c, b_c) / SIMD[DType.float64, 3](viewing_conditions.rgbD[0], viewing_conditions.rgbD[1], viewing_conditions.rgbD[2])
        #   var r_f = simd_f[0]
        #   var g_f = simd_f[1]
        #   var b_f = simd_f[2]

        var x: Float64 = 1.86206786 * r_f - 1.01125463 * g_f + 0.14918677 * b_f
        var y: Float64 = 0.38752654 * r_f + 0.62144744 * g_f - 0.00897398 * b_f
        var z: Float64 = -0.01584150 * r_f - 0.03412294 * g_f + 1.04996444 * b_f
        return StaticTuple[Float64, 3](x, y, z)

    def xyzInViewingConditions(
        self, viewing_conditions: ViewingConditions
    ) -> StaticTuple[Float64, 3]:
        return Self.xyz_in_viewing_conditions(self, viewing_conditions)


def float_pow(base: Float64, exponent: Float64) -> Float64:
    return base ** Float64(exponent)
