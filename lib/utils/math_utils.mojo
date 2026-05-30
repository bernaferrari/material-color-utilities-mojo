# Import required mathematical functions
from std.math import abs, div_ceil, min
from std.utils import StaticTuple


struct MathUtils:
    # The signum function.
    # Returns 1 if num > 0, -1 if num < 0, and 0 if num = 0
    @staticmethod
    def signum(num: Float64) -> Float64:
        if num < 0.0:
            return -1.0
        elif num > 0.0:
            return 1.0
        else:
            return 0.0

    # The linear interpolation function.
    # Returns start if amount = 0 and stop if amount = 1
    @staticmethod
    def lerp(start: Float64, stop: Float64, amount: Float64) -> Float64:
        return (1.0 - amount) * start + amount * stop

    # Clamps an integer between two integers.
    # Returns input when min <= input <= max, and either min or max otherwise.
    @staticmethod
    def clampInt(min: Int, max: Int, input: Int) -> Int:
        if input < min:
            return min
        elif input > max:
            return max
        else:
            return input

    # Clamps a floating-point number between two floating-point numbers.
    # Returns input when min <= input <= max, and either min or max otherwise.
    @staticmethod
    def clampDouble(min: Float64, max: Float64, input: Float64) -> Float64:
        if input < min:
            return min
        elif input > max:
            return max
        else:
            return input

    # Sanitizes a degree measure as an integer.
    # Returns a degree measure between 0 (inclusive) and 360 (exclusive).
    @staticmethod
    def sanitizeDegreesInt(degrees: Int) -> Int:
        var localDegrees = degrees % 360
        if localDegrees < 0:
            localDegrees += 360
        return localDegrees

    comptime type = DType.float64

    # Sanitizes a degree measure as a floating-point number.
    # Returns a degree measure between 0.0 (inclusive) and 360.0 (exclusive).
    @staticmethod
    def sanitizeDegreesDouble(degrees: Float64) -> Float64:
        var localDegrees = degrees % 360.0
        if localDegrees < 0.0:
            localDegrees += 360.0
        return localDegrees

    # Sign of direction change needed to travel from one angle to another.
    # Returns -1 if decreasing from leads to the shortest travel distance, 1 if increasing from leads to the shortest travel distance.
    @staticmethod
    def rotationDirection(fromValue: Float64, toValue: Float64) -> Float64:
        var increasingDifference = MathUtils.sanitizeDegreesDouble(
            toValue - fromValue
        )
        if increasingDifference <= 180.0:
            return 1.0
        else:
            return -1

    # Distance of two points on a circle, represented using degrees.
    @staticmethod
    def differenceDegrees(a: Float64, b: Float64) -> Float64:
        return 180.0 - abs(abs(a - b) - 180.0)

    # # Multiplies a 1x3 row vector with a 3x3 matrix.
    @staticmethod
    def matrixMultiply(
        row: StaticTuple[Float64, 3],
        matrix: StaticTuple[StaticTuple[Float64, 3], 3],
    ) -> StaticTuple[Float64, 3]:
        # # Load the row into a SIMD vector once, then use it for all operations
        # var simd_row = SIMD[DType.float64, 4](row[0], row[1], row[2])

        # #  Perform the SIMD multiplications for each row of the matrix
        # var simd_a = simd_row * SIMD[DType.float64, 4](matrix[0][0], matrix[0][1], matrix[0][2])
        # var simd_b = simd_row * SIMD[DType.float64, 4](matrix[1][0], matrix[1][1], matrix[1][2])
        # var simd_c = simd_row * SIMD[DType.float64, 4](matrix[2][0], matrix[2][1], matrix[2][2])

        # #  Combine the results using scalar addition since we don't have horizontal add
        # #  Note: Accessing SIMD elements directly like arrays; actual methods may differ
        # var a = simd_a[0] + simd_a[1] + simd_a[2]
        # var b = simd_b[0] + simd_b[1] + simd_b[2]
        # var c = simd_c[0] + simd_c[1] + simd_c[2]

        # #  Return the result as a static tuple
        # return StaticTuple[Float64, 3](a, b, c)

        # Previous code:
        var a = (
            row[0] * matrix[0][0]
            + row[1] * matrix[0][1]
            + row[2] * matrix[0][2]
        )
        var b = (
            row[0] * matrix[1][0]
            + row[1] * matrix[1][1]
            + row[2] * matrix[1][2]
        )
        var c = (
            row[0] * matrix[2][0]
            + row[1] * matrix[2][1]
            + row[2] * matrix[2][2]
        )
        return StaticTuple[Float64, 3](a, b, c)
