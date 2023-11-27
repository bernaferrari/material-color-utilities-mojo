from .color_utils import ColorUtils


fn int_to_hex(number: Int) -> String:
    let hex_digits = String("0123456789ABCDEF")
    var hex_str = String("")
    var min_length: Int = 2
    var num = number

    while num > 0 or min_length > 0:
        hex_str = hex_digits[num % 16] + hex_str
        num //= 16
        min_length -= 1

    return hex_str


struct StringUtils:
    @staticmethod
    fn hexFromArgb(argb: Int) -> String:
        let red: Int = ColorUtils.redFromArgb(argb)
        let green: Int = ColorUtils.greenFromArgb(argb)
        let blue: Int = ColorUtils.blueFromArgb(argb)

        let combinedStrings = int_to_hex(red) + int_to_hex(green) + int_to_hex(blue)
        return combinedStrings

    # @staticmethod
    # fn argb_from_hex(hex_str):
    #     try:
    #         return int(hex_str.replace("#", ""), 16)
    #     except ValueError:
    #         return None
