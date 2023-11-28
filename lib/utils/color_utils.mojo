# This file is automatically generated. Do not modify it.

from math import pow, round
from .math_utils import MathUtils


# Color science utilities.
# Utility methods for color science constants and color space
# conversions that aren't HCT or CAM16.
struct ColorUtils:
    alias _srgbToXyz = StaticTuple[3, StaticTuple[3, Float32]](
        StaticTuple[3, Float32](0.41233895, 0.35762064, 0.18051042),
        StaticTuple[3, Float32](0.2126, 0.7152, 0.0722),
        StaticTuple[3, Float32](0.01932141, 0.11916382, 0.95034478),
    )

    alias _xyzToSrgb = StaticTuple[3, StaticTuple[3, Float32]](
        StaticTuple[3, Float32](
            3.2413774792388685, -1.5376652402851851, -0.49885366846268053
        ),
        StaticTuple[3, Float32](
            -0.9691452513005321, 1.8758853451067872, 0.04156585616912061
        ),
        StaticTuple[3, Float32](
            0.05562093689691305, -0.20395524564742123, 1.0571799111220335
        ),
    )

    alias whitePointD65 = StaticTuple[3, Float32](95.047, 100.0, 108.883)

    # Converts a color from RGB components to ARGB format.
    @staticmethod
    fn argbFromRgb(red: Int, green: Int, blue: Int) -> Int:
        return (255 << 24) | ((red & 255) << 16) | ((green & 255) << 8) | (blue & 255)

    # Converts a color from linear RGB components to ARGB format.
    @staticmethod
    fn argbFromLinrgb(linrgb: StaticTuple[3, Float32]) -> Int:
        let r = ColorUtils.delinearized(linrgb[0])
        let g = ColorUtils.delinearized(linrgb[1])
        let b = ColorUtils.delinearized(linrgb[2])
        return ColorUtils.argbFromRgb(r, g, b)

    # Returns the alpha component of a color in ARGB format.
    @staticmethod
    fn alphaFromArgb(argb: Int) -> Int:
        return (argb >> 24) & 255

    # Returns the red component of a color in ARGB format.
    @staticmethod
    fn redFromArgb(argb: Int) -> Int:
        return (argb >> 16) & 255

    # Returns the green component of a color in ARGB format.
    @staticmethod
    fn greenFromArgb(argb: Int) -> Int:
        return (argb >> 8) & 255

    # Returns the blue component of a color in ARGB format.
    @staticmethod
    fn blueFromArgb(argb: Int) -> Int:
        return argb & 255

    # Returns whether a color in ARGB format is opaque.
    @staticmethod
    fn isOpaque(argb: Int) -> Bool:
        return ColorUtils.alphaFromArgb(argb) >= 255

    # Converts a color from ARGB to XYZ.
    @staticmethod
    fn argbFromXyz(x: Float32, y: Float32, z: Float32) -> Int:
        let matrix = Self._xyzToSrgb
        let linearR = matrix[0][0] * x + matrix[0][1] * y + matrix[0][2] * z
        let linearG = matrix[1][0] * x + matrix[1][1] * y + matrix[1][2] * z
        let linearB = matrix[2][0] * x + matrix[2][1] * y + matrix[2][2] * z
        let r = ColorUtils.delinearized(linearR)
        let g = ColorUtils.delinearized(linearG)
        let b = ColorUtils.delinearized(linearB)
        return ColorUtils.argbFromRgb(r, g, b)

    # Converts a color from XYZ to ARGB.
    @staticmethod
    fn xyzFromArgb(argb: Int) -> StaticTuple[3, Float32]:
        let r = ColorUtils.linearized(ColorUtils.redFromArgb(argb))
        let g = ColorUtils.linearized(ColorUtils.greenFromArgb(argb))
        let b = ColorUtils.linearized(ColorUtils.blueFromArgb(argb))

        return MathUtils.matrixMultiply(
            StaticTuple[3, Float32](r, g, b), ColorUtils._srgbToXyz
        )

    # Converts a color represented in Lab color space into an ARGB integer.
    @staticmethod
    fn argbFromLab(l: Float32, a: Float32, b: Float32) -> Int:
        let whitePoint = Self.whitePointD65
        let fy = (l + 16.0) / 116.0
        let fx = a / 500.0 + fy
        let fz = fy - b / 200.0
        let xNormalized = ColorUtils.labInvf(fx)
        let yNormalized = ColorUtils.labInvf(fy)
        let zNormalized = ColorUtils.labInvf(fz)
        let x = xNormalized * whitePoint.__getitem__(0)
        let y = yNormalized * whitePoint.__getitem__(1)
        let z = zNormalized * whitePoint.__getitem__(2)
        return ColorUtils.argbFromXyz(x, y, z)

    # Converts a color from ARGB representation to L*a*b* representation.
    @staticmethod
    fn labFromArgb(argb: Int) -> StaticTuple[3, Float32]:
        let linearR = ColorUtils.linearized(ColorUtils.redFromArgb(argb))
        let linearG = ColorUtils.linearized(ColorUtils.greenFromArgb(argb))
        let linearB = ColorUtils.linearized(ColorUtils.blueFromArgb(argb))
        let matrix = ColorUtils._srgbToXyz
        let x = matrix[0][0] * linearR + matrix[0][1] * linearG + matrix[0][2] * linearB
        let y = matrix[1][0] * linearR + matrix[1][1] * linearG + matrix[1][2] * linearB
        let z = matrix[2][0] * linearR + matrix[2][1] * linearG + matrix[2][2] * linearB
        let whitePoint = ColorUtils.whitePointD65
        let xNormalized = x / whitePoint.__getitem__(0)
        let yNormalized = y / whitePoint.__getitem__(1)
        let zNormalized = z / whitePoint.__getitem__(2)
        let fx = ColorUtils.labF(xNormalized)
        let fy = ColorUtils.labF(yNormalized)
        let fz = ColorUtils.labF(zNormalized)
        let l = 116.0 * fy - 16
        let a_val = 500.0 * (fx - fy)
        let b_val = 200.0 * (fy - fz)

        return StaticTuple[3, Float32](l, a_val, b_val)
        # return [l, a_val, b_val]

    # Converts an L* value to an ARGB representation.
    @staticmethod
    fn argbFromLstar(lstar: Float32) -> Int:
        let y = ColorUtils.yFromLstar(lstar)
        let component = ColorUtils.delinearized(y)
        return ColorUtils.argbFromRgb(component, component, component)

    # Computes the L* value of a color in ARGB representation.
    @staticmethod
    fn lstarFromArgb(argb: Int) -> Float32:
        let y = Self.xyzFromArgb(argb)[1]
        return 116 * Self.labF(y / 100.0) - 16

    # Converts an L* value to a Y value.
    @staticmethod
    fn yFromLstar(lstar: Float32) -> Float32:
        return 100 * Self.labInvf((lstar + 16) / 116.0)

    # Converts a Y value to an L* value.
    @staticmethod
    fn lstarFromY(y: Float32) -> Float32:
        return Self.labF(y / 100) * 116 - 16

    # Linearizes an RGB component.
    @staticmethod
    fn linearized(rgbComponent: Int) -> Float32:
        let normalized = rgbComponent / 255.0
        if normalized <= 0.040449936:
            return normalized / 12.92 * 100.0
        else:
            return (((normalized + 0.055) / 1.055) ** 2.4) * 100.0

    # Delinearizes an RGB component.
    @staticmethod
    fn delinearized(rgbComponent: Float32) -> Int:
        let normalized = rgbComponent / 100.0
        var delinearizedValue: Float32 = 0.0
        if normalized <= 0.0031308:
            delinearizedValue = normalized * 12.92
        else:
            delinearizedValue = 1.055 * (normalized ** (1.0 / 2.4)) - 0.055
        return MathUtils.clampInt(0, 255, round(delinearizedValue * 255.0).to_int())

    @staticmethod
    fn labF(t: Float32) -> Float32:
        let e = 216.0 / 24389.0
        let kappa = 24389.0 / 27.0
        if t > e:
            return t ** (1.0 / 3.0)
        else:
            return (kappa * t + 16) / 116

    @staticmethod
    fn labInvf(ft: Float32) -> Float32:
        let e = 216.0 / 24389.0
        let kappa = 24389.0 / 27.0
        let ft3 = ft * ft * ft
        if ft3 > e:
            return ft3
        else:
            return (116 * ft - 16) / kappa
