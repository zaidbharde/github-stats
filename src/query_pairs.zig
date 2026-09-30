const std = @import("std");

pub const Pair = struct { key: []const u8, value: []const u8 };

pub fn next(input: []const u8, cursor: *usize) ?Pair {
    if (cursor.* >= input.len) return null;
    const start = cursor.*;
    const end = std.mem.indexOfScalarPos(u8, input, start, '&') orelse input.len;
    cursor.* = if (end < input.len) end + 1 else end;
    const part = input[start..end];
    const split = std.mem.indexOfScalar(u8, part, '=') orelse part.len;
    return .{ .key = part[0..split], .value = if (split < part.len) part[split + 1 ..] else "" };
}

pub fn count(input: []const u8) usize {
    if (input.len == 0) return 0;
    var cursor: usize = 0;
    var total: usize = 0;
    while (next(input, &cursor)) |_| total += 1;
    return total;
}

test "query pairs preserve empty values and ampersands" {
    const query = "q=zig&sort=desc&flag&empty=";
    try std.testing.expectEqual(@as(usize, 4), count(query));
    var cursor: usize = 0;
    const first = next(query, &cursor).?;
    try std.testing.expectEqualStrings("q", first.key);
    try std.testing.expectEqualStrings("zig", first.value);
    _ = next(query, &cursor);
    _ = next(query, &cursor);
    const last = next(query, &cursor).?;
    try std.testing.expectEqualStrings("empty", last.key);
    try std.testing.expectEqualStrings("", last.value);
}
