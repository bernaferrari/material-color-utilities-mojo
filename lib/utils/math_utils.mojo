# Import required mathematical functions
from math import abs, div_ceil, min


struct MathUtils:
    # The signum function.
    # Returns 1 if num > 0, -1 if num < 0, and 0 if num = 0
    @staticmethod
    fn signum(num: Float32) -> Int:
        if num < 0.0:
            return -1
        elif num > 0.0:
            return 1
        else:
            return 0

    # The linear interpolation function.
    # Returns start if amount = 0 and stop if amount = 1
    @staticmethod
    fn lerp(start: Float32, stop: Float32, amount: Float32) -> Float32:
        return (1.0 - amount) * start + amount * stop

    # Clamps an integer between two integers.
    # Returns input when min <= input <= max, and either min or max otherwise.
    @staticmethod
    fn clampInt(min: Int, max: Int, input: Int) -> Int:
        if input < min:
            return min
        elif input > max:
            return max
        else:
            return input

    # Clamps a floating-point number between two floating-point numbers.
    # Returns input when min <= input <= max, and either min or max otherwise.
    @staticmethod
    fn clampDouble(min: Float32, max: Float32, input: Float32) -> Float32:
        if input < min:
            return min
        elif input > max:
            return max
        else:
            return input

    # Sanitizes a degree measure as an integer.
    # Returns a degree measure between 0 (inclusive) and 360 (exclusive).
    @staticmethod
    fn sanitizeDegreesInt(degrees: Int) -> Int:
        var localDegrees = degrees % 360
        if localDegrees < 0:
            localDegrees += 360
        return degrees

    alias type = DType.float32

    # Sanitizes a degree measure as a floating-point number.
    # Returns a degree measure between 0.0 (inclusive) and 360.0 (exclusive).
    @staticmethod
    fn sanitizeDegreesDouble(degrees: Float32) -> Float32:
        var localDegrees = degrees % 360.0
        if localDegrees < 0.0:
            localDegrees += 360.0
        return localDegrees

    # Sign of direction change needed to travel from one angle to another.
    # Returns -1 if decreasing from leads to the shortest travel distance, 1 if increasing from leads to the shortest travel distance.
    @staticmethod
    fn rotationDirection(fromValue: Float32, toValue: Float32) -> Float32:
        let increasingDifference = MathUtils.sanitizeDegreesDouble(toValue - fromValue)
        if increasingDifference <= 180.0:
            return 1.0
        else:
            return -1

    # Distance of two points on a circle, represented using degrees.
    @staticmethod
    fn differenceDegrees(a: Float32, b: Float32) -> Float32:
        return 180.0 - abs(abs(a - b) - 180.0)

    # # Multiplies a 1x3 row vector with a 3x3 matrix.
    @staticmethod
    fn matrixMultiply(
        row: StaticTuple[3, Float32], matrix: StaticTuple[3, StaticTuple[3, Float32]]
    ) -> StaticTuple[3, Float32]:
        # # Load the row into a SIMD vector once, then use it for all operations
        # let simd_row = SIMD[DType.float32, 4](row[0], row[1], row[2])

        # #  Perform the SIMD multiplications for each row of the matrix
        # let simd_a = simd_row * SIMD[DType.float32, 4](matrix[0][0], matrix[0][1], matrix[0][2])
        # let simd_b = simd_row * SIMD[DType.float32, 4](matrix[1][0], matrix[1][1], matrix[1][2])
        # let simd_c = simd_row * SIMD[DType.float32, 4](matrix[2][0], matrix[2][1], matrix[2][2])

        # #  Combine the results using scalar addition since we don't have horizontal add
        # #  Note: Accessing SIMD elements directly like arrays; actual methods may differ
        # let a = simd_a[0] + simd_a[1] + simd_a[2]
        # let b = simd_b[0] + simd_b[1] + simd_b[2]
        # let c = simd_c[0] + simd_c[1] + simd_c[2]

        # #  Return the result as a static tuple
        # return StaticTuple[3, Float32](a, b, c)

        # Previous code:
        let a = row[0] * matrix[0][0] + row[1] * matrix[0][1] + row[2] * matrix[0][2]
        let b = row[0] * matrix[1][0] + row[1] * matrix[1][1] + row[2] * matrix[1][2]
        let c = row[0] * matrix[2][0] + row[1] * matrix[2][1] + row[2] * matrix[2][2]
        return StaticTuple[3, Float32](a, b, c)