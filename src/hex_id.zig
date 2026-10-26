const std = @import("std");

pub fn decodeHex(input: []const u8, output: []u8) !usize {
    if (input.len % 2 != 0) return error.OddLength;
    const needed = input.len / 2;
    if (output.len < needed) return error.OutputTooSmall;
    var index: usize = 0;
    while (index < needed) : (index += 1) {
        const high = digit(input[index * 2]) orelse return error.InvalidDigit;
        const low = digit(input[index * 2 + 1]) orelse return error.InvalidDigit;
        output[index] = high * 16 + low;
    }
    return needed;
}

fn digit(value: u8) ?u8 {
    return switch (value) {
        '0'...'9' => value - '0',
        'a'...'f' => value - 'a' + 10,
        'A'...'F' => value - 'A' + 10,
        else => null,
    };
}

test "decodes mixed-case hexadecimal" {
    var output: [3]u8 = undefined;
    const length = try decodeHex("a1B20f", &output);
    try std.testing.expectEqual(@as(usize, 3), length);
    try std.testing.expectEqualSlices(u8, &[_]u8{ 0xa1, 0xb2, 0x0f }, output[0..length]);
}
