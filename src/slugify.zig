const std = @import("std");

pub fn writeSlug(input: []const u8, output: []u8) ![]u8 {
    var length: usize = 0;
    var pending_dash = false;
    for (input) |character| {
        if (std.ascii.isAlphanumeric(character)) {
            if (pending_dash and length > 0) {
                if (length == output.len) return error.BufferTooSmall;
                output[length] = '-';
                length += 1;
            }
            pending_dash = false;
            if (length == output.len) return error.BufferTooSmall;
            output[length] = std.ascii.toLower(character);
            length += 1;
        } else if (length > 0) {
            pending_dash = true;
        }
    }
    return output[0..length];
}

test "slug removes repeated separators" {
    var buffer: [32]u8 = undefined;
    try std.testing.expectEqualStrings("daily-metric-7", try writeSlug("Daily  metric #7", &buffer));
}
