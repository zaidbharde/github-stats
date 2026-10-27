const std = @import("std");

/// Count integer samples into a fixed number of equally sized buckets.
pub fn compactHistogram(allocator: std.mem.Allocator, values: []const u32, bucket_count: u32) ![]u32 {
    if (bucket_count == 0) return error.InvalidBucketCount;
    const buckets = try allocator.alloc(u32, bucket_count);
    @memset(buckets, 0);
    for (values) |value| {
        const bucket = @min(value / bucket_count, bucket_count - 1);
        buckets[bucket] += 1;
    }
    return buckets;
}

test "histogram saturates the final bucket" {
    const values = [_]u32{ 0, 1, 5, 8, 19 };
    const result = try compactHistogram(std.testing.allocator, &values, 4);
    defer std.testing.allocator.free(result);
    try std.testing.expectEqualSlices(u32, &[_]u32{ 2, 1, 0, 2 }, result);
}
