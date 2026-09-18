const std = @import("std");

pub fn compact(value: u64, buffer: []u8) ![]u8 {
    const suffixes = [_][]const u8{ "", "k", "M", "G", "T" };
    var scaled: f64 = @floatFromInt(value);
    var index: usize = 0;
    while (scaled >= 1000 and index + 1 < suffixes.len) : (index += 1) {
        scaled /= 1000;
    }
    if (index == 0) return std.fmt.bufPrint(buffer, "{d}", .{value});
    return std.fmt.bufPrint(buffer, "{d:.1}{s}", .{ scaled, suffixes[index] });
}

test "compact formatter preserves small values" {
    var buffer: [32]u8 = undefined;
    try std.testing.expectEqualStrings("842", try compact(842, &buffer));
    try std.testing.expectEqualStrings("1.5k", try compact(1500, &buffer));
}
