const std = @import("std");

pub const Error = error{InvalidLength, InvalidDigit};

pub fn encode(input: []const u8, output: []u8) Error!void {
    if (output.len < input.len * 2) return error.InvalidLength;
    const alphabet = "0123456789abcdef";
    for (input, 0..) |byte, index| {
        output[index * 2] = alphabet[byte >> 4];
        output[index * 2 + 1] = alphabet[byte & 0x0f];
    }
}

fn digit(value: u8) Error!u8 {
    return switch (value) {
        '0'...'9' => value - '0',
        'a'...'f' => value - 'a' + 10,
        'A'...'F' => value - 'A' + 10,
        else => error.InvalidDigit,
    };
}

pub fn decode(input: []const u8, output: []u8) Error!void {
    if (input.len % 2 != 0 or output.len < input.len / 2) return error.InvalidLength;
    var index: usize = 0;
    while (index < input.len) : (index += 2) {
        output[index / 2] = try digit(input[index]) * 16 + try digit(input[index + 1]);
    }
}

test "hex codec round trips bytes" {
    const source = [_]u8{ 0, 15, 16, 127, 255 };
    var encoded: [10]u8 = undefined;
    var decoded: [5]u8 = undefined;
    try encode(&source, &encoded);
    try std.testing.expectEqualStrings("000f107fff", &encoded);
    try decode("000F107fFF", &decoded);
    try std.testing.expectEqualSlices(u8, &source, &decoded);
}
