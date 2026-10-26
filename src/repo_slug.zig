const std = @import("std");

pub fn writeSlug(input: []const u8, output: []u8) !usize {
    var length: usize = 0;
    var pending_dash = false;
    for (input) |value| {
        if (std.ascii.isAlphanumeric(value)) {
            if (pending_dash and length > 0) {
                if (length == output.len) return error.OutputTooSmall;
                output[length] = '-';
                length += 1;
            }
            if (length == output.len) return error.OutputTooSmall;
            output[length] = std.ascii.toLower(value);
            length += 1;
            pending_dash = false;
        } else if (length > 0) {
            pending_dash = true;
        }
    }
    return length;
}

test "collapses punctuation into one separator" {
    var output: [32]u8 = undefined;
    const length = try writeSlug("  API Gateway / v2  ", &output);
    try std.testing.expectEqualStrings("api-gateway-v2", output[0..length]);
}
