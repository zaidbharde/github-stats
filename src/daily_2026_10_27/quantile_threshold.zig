const std = @import("std");

/// Return the smallest sorted value whose cumulative rank reaches the target.
pub fn quantileThreshold(values: []const u32, numerator: u32, denominator: u32) !u32 {
    if (values.len == 0 or denominator == 0 or numerator > denominator) {
        return error.InvalidQuantile;
    }
    const copy = try std.heap.page_allocator.alloc(u32, values.len);
    defer std.heap.page_allocator.free(copy);
    @memcpy(copy, values);
    std.sort.heap(u32, copy, {}, comptime std.sort.asc(u32));
    const scaled = @as(u64, numerator) * @as(u64, copy.len - 1);
    const index = @as(usize, @intCast((scaled + denominator - 1) / denominator));
    return copy[index];
}

test "quantile threshold rounds toward the upper rank" {
    const values = [_]u32{ 10, 2, 7, 4 };
    try std.testing.expectEqual(@as(u32, 7), try quantileThreshold(&values, 2, 3));
}
