const std = @import("std");

pub fn fnv1a(input: []const u8) u64 {
    var hash: u64 = 14695981039346656037;
    for (input) |byte| {
        hash ^= byte;
        hash *%= 1099511628211;
    }
    return hash;
}

pub fn bucket(input: []const u8, count: usize) usize {
    if (count == 0) return 0;
    return @as(usize, @intCast(fnv1a(input) % count));
}

test "fnv1a remains stable for common keys" {
    try std.testing.expectEqual(@as(u64, 14695981039346656037), fnv1a(""));
    try std.testing.expectEqual(@as(u64, 11831194018420276491), fnv1a("a"));
    try std.testing.expectEqual(@as(usize, 0), bucket("ignored", 0));
    try std.testing.expect(bucket("user-42", 7) < 7);
}
