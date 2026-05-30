from .color_utils import ColorUtils


def int_to_hex(number: Int) -> String:
    var hex_digits = String("0123456789ABCDEF")
    var hex_str = String("")
    var min_length: Int = 2
    var num = number

    while num > 0 or min_length > 0:
        hex_str = String(hex_digits[byte=num % 16]) + hex_str
        num //= 16
        min_length -= 1

    return hex_str


def hex_digit_value(digit: String) -> Int:
    if digit == "0":
        return 0
    if digit == "1":
        return 1
    if digit == "2":
        return 2
    if digit == "3":
        return 3
    if digit == "4":
        return 4
    if digit == "5":
        return 5
    if digit == "6":
        return 6
    if digit == "7":
        return 7
    if digit == "8":
        return 8
    if digit == "9":
        return 9
    if digit == "a" or digit == "A":
        return 10
    if digit == "b" or digit == "B":
        return 11
    if digit == "c" or digit == "C":
        return 12
    if digit == "d" or digit == "D":
        return 13
    if digit == "e" or digit == "E":
        return 14
    if digit == "f" or digit == "F":
        return 15
    return -1


struct StringUtils:
    @staticmethod
    def hexFromArgb(argb: Int, leading_hash_sign: Bool = True) -> String:
        var red: Int = ColorUtils.redFromArgb(argb)
        var green: Int = ColorUtils.greenFromArgb(argb)
        var blue: Int = ColorUtils.blueFromArgb(argb)

        var combinedStrings = (
            int_to_hex(red) + int_to_hex(green) + int_to_hex(blue)
        )
        if leading_hash_sign:
            return String("#") + combinedStrings
        return combinedStrings

    @staticmethod
    def argbFromHex(hex: String) -> Int:
        var answer = 0
        var digits = 0
        for i in range(hex.byte_length()):
            var digit = String(hex[byte=i])
            if digit == "#":
                continue
            var value = hex_digit_value(digit)
            if value < 0:
                return -1
            answer = (answer << 4) + value
            digits += 1
        if digits == 0:
            return -1
        return answer
