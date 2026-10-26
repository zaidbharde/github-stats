const std = @import("std");

pub const Counter = struct {
    key: []const u8,
    value: u32,
};

pub fn increment(counters: []Counter, key: []const u8) bool {
    for (counters) |*counter| {
        if (std.mem.eql(u8, counter.key, key)) {
            counter.value +|= 1;
            return true;
        }
    }
    for (counters) |*counter| {
        if (counter.key.len == 0) {
            counter.key = key;
            counter.value = 1;
            return true;
        }
    }
    return false;
}

pub fn total(counters: []const Counter) u64 {
    var result: u64 = 0;
    for (counters) |counter| result += counter.value;
    return result;
}

test "increments existing keys and fills empty slots" {
    var counters = [_]Counter{
        .{ .key = "", .value = 0 },
        .{ .key = "", .value = 0 },
    };
    try std.testing.expect(increment(&counters, "push"));
    try std.testing.expect(increment(&counters, "push"));
    try std.testing.expect(increment(&counters, "issue"));
    try std.testing.expectEqual(@as(u32, 2), counters[0].value);
    try std.testing.expectEqual(@as(u64, 3), total(&counters));
}
