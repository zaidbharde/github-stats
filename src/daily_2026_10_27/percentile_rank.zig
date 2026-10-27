const std = @import("std");

/// Return the fraction of sorted values less than or equal to target.
pub fn percentileRank(values: []const f64, target: f64) f64 {
    if (values.len == 0) return 0.0;
    var below: usize = 0;
    for (values) |value| {
        if (value <= target) below += 1;
    }
    return @as(f64, @floatFromInt(below)) / @as(f64, @floatFromInt(values.len));
}

test "percentile rank handles ties" {
    const values = [_]f64{ 1.0, 2.0, 2.0, 4.0 };
    try std.testing.expectApproxEqAbs(@as(f64, 0.75), percentileRank(&values, 2.0), 0.0001);
}
