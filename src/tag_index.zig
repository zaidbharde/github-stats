const std = @import("std");

pub const TagCount = struct {
    tag: []const u8,
    count: u32,
};

pub fn increment(entries: []TagCount, tag: []const u8) bool {
    for (entries) |*entry| {
        if (std.mem.eql(u8, entry.tag, tag)) {
            entry.count += 1;
            return true;
        }
    }
    return false;
}

pub fn top(entries: []const TagCount) ?TagCount {
    if (entries.len == 0) return null;
    var best = entries[0];
    for (entries[1..]) |entry| {
        if (entry.count > best.count) best = entry;
    }
    return best;
}

test "tag index increments and selects the leader" {
    var entries = [_]TagCount{
        .{ .tag = "zig", .count = 1 },
        .{ .tag = "rust", .count = 3 },
    };
    try std.testing.expect(increment(&entries, "zig"));
    try std.testing.expectEqualStrings("rust", top(&entries).?.tag);
}
