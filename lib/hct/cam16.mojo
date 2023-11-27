import math
from lib.utils.color_utils import ColorUtils
from lib.utils.math_utils import signum
from lib.hct.viewing_conditions import ViewingConditions

alias MathPi = 3.141592653589793238462643383279502884197169399375105820974944592307816406286208998628034825342117067982148086513282306647093844609550582231725359408128481117450284102701938521105559644622948954930381964428810975665933446128475648233786783165271201909145648566923460348610454326648213393607260249141273

struct Cam16:
    var hue: Float32
    var chroma: Float32
    var j: Float32
    var q: Float32
    var m: Float32
    var s: Float32
    var jstar: Float32
    var astar: Float32
    var bstar: Float32

  fn __init__(
    inout self,
      hue: Float32,
      chroma: Float32,
      j: Float32,
      q: Float32,
      m: Float32,
      s: Float32,
      jstar: Float32,
      astar: Float32,
      bstar: Float32,
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

  fn distance(cam16_1: Cam16, cam16_2: Cam16) -> Float32:
      let dJ: Float32 = cam16_1.jstar - cam16_2.jstar
      let dA: Float32 = cam16_1.astar - cam16_2.astar
      let dB: Float32 = cam16_1.bstar - cam16_2.bstar
      let dEPrime: Float32 = math.sqrt(dJ * dJ + dA * dA + dB * dB)
      let dE: Float32 = 1.41 * (dEPrime**0.63)
      return dE

  @staticmethod
  fn from_int(argb: Int) -> Cam16:
      return Self.from_int_in_viewing_conditions(argb, ViewingConditions.srgb())

  @staticmethod
  fn from_int_in_viewing_conditions(argb: Int, viewing_conditions: ViewingConditions
  ) -> Cam16:
      let xyz = ColorUtils.xyzFromArgb(argb)
      let x: Float32 = xyz[0]
      let y: Float32 = xyz[1]
      let z: Float32 = xyz[2]
      return Self.from_xyz_in_viewing_conditions(x, y, z, viewing_conditions)

  @staticmethod
  fn from_xyz_in_viewing_conditions(
      x: Float32, y: Float32, z: Float32, viewing_conditions: ViewingConditions
  ) -> Cam16:
      let rC: Float32 = 0.401288 * x + 0.650173 * y - 0.051461 * z
      let gC: Float32 = -0.250268 * x + 1.204414 * y + 0.045854 * z
      let bC: Float32 = -0.002079 * x + 0.048952 * y + 0.953127 * z      

      let rD: Float32 = viewing_conditions.rgbD[0] * rC
      let gD: Float32 = viewing_conditions.rgbD[1] * gC
      let bD: Float32 = viewing_conditions.rgbD[2] * bC

      let rA: Float32 = 400.0 * (
          viewing_conditions.fl * math.abs(rD) / 100.0 ** 0.42
      ) / ((viewing_conditions.fl * math.abs(rD) / 100.0 ** 0.42) + 27.13)
      let gA: Float32 = 400.0 * (
          viewing_conditions.fl * math.abs(gD) / 100.0 ** 0.42
      ) / ((viewing_conditions.fl * math.abs(gD) / 100.0 ** 0.42) + 27.13)
      let bA: Float32 = 400.0 * ((
          viewing_conditions.fl * math.abs(bD) / 100.0) ** 0.42
      ) / (((viewing_conditions.fl * math.abs(bD) / 100.0) ** 0.42) + 27.13)

      let a: Float32 = (11.0 * rA + -12.0 * gA + bA) / 11.0
      let b: Float32 = (rA + gA - 2.0 * bA) / 9.0
      let u: Float32 = (20.0 * rA + 20.0 * gA + 21.0 * bA) / 20.0
      let p2: Float32 = (40.0 * rA + 20.0 * gA + bA) / 20.0

      let atan2_b_a: Float32 = math.atan2(b, a)
      let atan_degrees: Float32 = atan2_b_a * 180.0 / MathPi
      let hue: Float32 = atan_degrees if atan_degrees >= 0 else atan_degrees + 360.0
      let hue_radians: Float32 = hue * MathPi / 180.0

      let ac: Float32 = p2 * viewing_conditions.nbb
      let j: Float32 = 100.0 * math.pow(
          ac / viewing_conditions.aw, viewing_conditions.c * viewing_conditions.z
      )
      let q: Float32 = (4.0 / viewing_conditions.c) * math.sqrt(j / 100.0) * (
          viewing_conditions.aw + 4.0
      ) * viewing_conditions.fLRoot

      let hue_prime: Float32 = hue if hue >= 20.14 else hue + 360
      let e_hue: Float32 = (math.cos(hue_prime * MathPi / 180.0 + 2.0) + 3.8) / 4.0
      let p1: Float32 = 50000.0 / 13.0 * e_hue * viewing_conditions.nC * viewing_conditions.ncb
      let t: Float32 = p1 * math.sqrt(a * a + b * b) / (u + 0.305)

      let alpha: Float32 = (t ** 0.9) * float_pow(
          (1.64 - (float_pow(0.29, viewing_conditions.backgroundYTowhitePointY))), 0.73
      )
      let c: Float32 = alpha * math.sqrt(j / 100.0)
      let m: Float32 = c * viewing_conditions.fLRoot
      let s: Float32 = 50.0 * math.sqrt(
          (alpha * viewing_conditions.c) / (viewing_conditions.aw + 4.0)
      )
      let jstar: Float32 = (1.0 + 100.0 * 0.007) * j / (1.0 + 0.007 * j)
      let mstar: Float32 = math.log(1.0 + 0.0228 * m) / 0.0228
      let astar: Float32 = mstar * math.cos(hue_radians)
      let bstar: Float32 = mstar * math.sin(hue_radians)

      return Cam16(hue, c, j, q, m, s, jstar, astar, bstar)

  @staticmethod
  fn fromJch(j: Float32, c: Float32, h: Float32) -> Cam16:
    return Self.fromJchInViewingConditions(j, c, h, ViewingConditions.srgb())

  @staticmethod
  fn fromJchInViewingConditions(
    J: Float32, C: Float32, h: Float32, viewingConditions: ViewingConditions
  ) -> Cam16:
    let Q =
      (4.0 / viewingConditions.c) * math.sqrt(J / 100.0) * (viewingConditions.aw + 4.0)
      * (viewingConditions.fLRoot)
    let M = C * viewingConditions.fLRoot
    let alpha = C / math.sqrt(J / 100.0)
    let s = 50.0 * math.sqrt((alpha * viewingConditions.c) / (viewingConditions.aw + 4.0))

    let hueRadians = h * MathPi / 180
    let jstar = (1.0 + 100.0 * 0.007) * J / (1.0 + 0.007 * J)
    let mstar = 1.0 / 0.0228 * math.log(1.0 + 0.0228 * M)
    let astar = mstar * math.cos(hueRadians)
    let bstar = mstar * math.sin(hueRadians)
    return Cam16(h, C, J, Q, M, s, jstar, astar, bstar)

  # Create a CAM16 color from CAM16-UCS coordinates [jstar], [astar], [bstar].
  # assuming the color was viewed in default viewing conditions.
  @staticmethod
  fn fromUcs(jstar: Float32, astar: Float32, bstar: Float32) -> Cam16:
    return Self.fromUcsInViewingConditions(jstar, astar, bstar, ViewingConditions.standard())

  # Create a CAM16 color from CAM16-UCS coordinates [jstar], [astar], [bstar].
  # in [viewingConditions].
  @staticmethod
  fn fromUcsInViewingConditions(
    jstar: Float32, astar: Float32, bstar: Float32, viewingConditions: ViewingConditions
  ) -> Cam16:
    let a = astar
    let b = bstar
    let m = math.sqrt(a * a + b * b)
    let M = (math.exp(m * 0.0228) - 1.0) / 0.0228
    let c = M / viewingConditions.fLRoot
    var h = math.atan2(b, a) * (180.0 / MathPi)
    if h < 0.0:
      h += 360.0
    let j = jstar / (1 - (jstar - 100) * 0.007)

    return Self.fromJchInViewingConditions(j, c, h, viewingConditions)

  fn to_int(inout self: Cam16) -> Int:
      return self.viewed(self, ViewingConditions.srgb())

  fn viewed(inout self, cam16: Cam16, viewing_conditions: ViewingConditions) -> Int:
      let xyz: StaticTuple[3, Float32] = Self.xyz_in_viewing_conditions(cam16, viewing_conditions)
      return ColorUtils.argbFromXyz(xyz[0], xyz[1], xyz[2])

  fn xyz_in_viewing_conditions(
      cam16: Cam16, viewing_conditions: ViewingConditions
  ) -> StaticTuple[3, Float32]:
      let alpha: Float32 = cam16.chroma / math.sqrt(cam16.j / 100.0) if (
          cam16.chroma != 0.0 and cam16.j != 0.0
      ) else 0.0

      let t: Float32 = float_pow(
          alpha / (1.64 - float_pow(0.29, viewing_conditions.backgroundYTowhitePointY)),
          1.0 / 0.9,
      )
      let h_rad: Float32 = cam16.hue * MathPi / 180.0
      let e_hue = (math.cos(h_rad + 2.0) + 3.8) / 4.0
      let ac: Float32 = viewing_conditions.aw * math.pow(
          cam16.j / 100.0, 1.0 / (viewing_conditions.c * viewing_conditions.z)
      )
      let p1: Float32 = e_hue * (
          50000.0 / 13.0
      ) * viewing_conditions.nC * viewing_conditions.ncb
      let p2: Float32 = ac / viewing_conditions.nbb
      let h_sin: Float32 = math.sin(h_rad)
      let h_cos: Float32 = math.cos(h_rad)
      let gamma: Float32 = 23.0 * (p2 + 0.305) * t / (
          23.0 * p1 + 11 * t * h_cos + 108.0 * t * h_sin
      )
      let a: Float32 = gamma * h_cos
      let b: Float32 = gamma * h_sin
      let r_a: Float32 = (460.0 * p2 + 451.0 * a + 288.0 * b) / 1403.0
      let g_a: Float32 = (460.0 * p2 - 891.0 * a - 261.0 * b) / 1403.0
      let b_a: Float32 = (460.0 * p2 - 220.0 * a - 6300.0 * b) / 1403.0
      let r_c_base: Float32 = math.max(0, (27.13 * math.abs(r_a)) / (400 - math.abs(r_a)))
      let r_c: Float32 = signum(r_a) * (100.0 / viewing_conditions.fl) * float_pow(
          r_c_base, 1.0 / 0.42
      )
      let g_c_base: Float32 = math.max(0, (27.13 * math.abs(g_a)) / (400 - math.abs(g_a)))
      let g_c: Float32 = signum(g_a) * (100.0 / viewing_conditions.fl) * float_pow(
          g_c_base, 1.0 / 0.42
      )
      let b_c_base: Float32 = math.max(0, (27.13 * math.abs(b_a)) / (400 - math.abs(b_a)))
      let b_c: Float32 = signum(b_a) * (100.0 / viewing_conditions.fl) * float_pow(
          b_c_base, 1.0 / 0.42
      )
      let r_f: Float32 = r_c / viewing_conditions.rgbD[0]
      let g_f: Float32 = g_c / viewing_conditions.rgbD[1]
      let b_f: Float32 = b_c / viewing_conditions.rgbD[2]
      let x: Float32 = 1.86206786 * r_f - 1.01125463 * g_f + 0.14918677 * b_f
      let y: Float32 = 0.38752654 * r_f + 0.62144744 * g_f - 0.00897398 * b_f
      let z: Float32 = -0.01584150 * r_f - 0.03412294 * g_f + 1.04996444 * b_f
      return StaticTuple[3, Float32](x, y, z)


fn float_pow(base: Float32, exponent: Float32) -> Float32:
    return base ** Float32(exponent)
