# Import required mathematical functions
from math import abs, div_ceil, min

# The signum function.
# Returns 1 if num > 0, -1 if num < 0, and 0 if num = 0
fn signum(num: Float32) -> Int:
    if num < 0.0:
        return -1
    elif num > 0.0:
        return 1
    else:
        return 0


# The linear interpolation function.
# Returns start if amount = 0 and stop if amount = 1
fn lerp(start: Float32, stop: Float32, amount: Float32) -> Float32:
    return (1.0 - amount) * start + amount * stop


# Clamps an integer between two integers.
# Returns input when min <= input <= max, and either min or max otherwise.
fn clampInt(min: Int, max: Int, input: Int) -> Int:
    if input < min:
        return min
    elif input > max:
        return max
    else:
        return input


# Clamps a floating-point number between two floating-point numbers.
# Returns input when min <= input <= max, and either min or max otherwise.
fn clampDouble(min: Float32, max: Float32, input: Float32) -> Float32:
    if input < min:
        return min
    elif input > max:
        return max
    else:
        return input


# Sanitizes a degree measure as an integer.
# Returns a degree measure between 0 (inclusive) and 360 (exclusive).
fn sanitizeDegreesInt(degrees: Int) -> Int:
    var localDegrees = degrees % 360
    if localDegrees < 0:
        localDegrees += 360
    return degrees


alias type = DType.float32


# Sanitizes a degree measure as a floating-point number.
# Returns a degree measure between 0.0 (inclusive) and 360.0 (exclusive).
fn sanitizeDegreesDouble(degrees: Float32) -> Float32:
    var localDegrees = degrees % 360.0
    if localDegrees < 0.0:
        localDegrees += 360.0
    return localDegrees


# Sign of direction change needed to travel from one angle to another.
# Returns -1 if decreasing from leads to the shortest travel distance, 1 if increasing from leads to the shortest travel distance.
fn rotationDirection(fromValue: Float32, toValue: Float32) -> Float32:
    let increasingDifference = sanitizeDegreesDouble(toValue - fromValue)
    if (increasingDifference <= 180.0):
        return 1.0
    else:
        return -1


# Distance of two points on a circle, represented using degrees.
fn differenceDegrees(a: Float32, b: Float32) -> Float32:
    return 180.0 - abs(abs(a - b) - 180.0)


# # Multiplies a 1x3 row vector with a 3x3 matrix.
fn matrixMultiply(
    row: StaticTuple[3, Float32], matrix: StaticTuple[3, StaticTuple[3, Float32]]
) -> StaticTuple[3, Float32]:
    let a = row[0] * matrix[0][0] + row[1] * matrix[0][1] + row[2] * matrix[0][2]
    let b = row[0] * matrix[1][0] + row[1] * matrix[1][1] + row[2] * matrix[1][2]
    let c = row[0] * matrix[2][0] + row[1] * matrix[2][1] + row[2] * matrix[2][2]

    return StaticTuple[3, Float32](a, b, c)

# # Multiplies a 1x3 row vector with a 3x3 matrix.
# fn matrixMultiply(row: Tensor[DType.float32], matrix: Tensor[DType.float32]) -> Tensor[DType.float32]:
#     let a = row.at(0) * matrix.at(0, 0) + row.at(1) * matrix.at(0, 1) + row.at(2) * matrix.at(0, 2)
#     let b = row.at(0) * matrix.at(1, 0) + row.at(1) * matrix.at(1, 1) + row.at(2) * matrix.at(1, 2)
#     let c = row.at(0) * matrix.at(2, 0) + row.at(1) * matrix.at(2, 1) + row.at(2) * matrix.at(2, 2)
#     return Tensor[Float32]([a, b, c], [3])  # Assuming 3 elements in the return vector.
