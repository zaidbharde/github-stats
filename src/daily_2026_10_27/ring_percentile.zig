const std = @import("std");

/// Calculate a percentile from a caller-owned mutable copy of samples.
pub fn nearestRankPercentile(samples: []f64, percentile: f64) !f64 {
    if (samples.len == 0) return error.EmptyInput;
    if (percentile < 0.0 or percentile > 1.0) return error.InvalidPercentile;
    std.sort.heap(f64, samples, {}, std.sort.asc(f64));
    const scaled = percentile * @as(f64, @floatFromInt(samples.len - 1));
    return samples[@intFromFloat(@ceil(scaled))];
}

test "nearest rank is inclusive" {
    var values = [_]f64{ 8.0, 1.0, 4.0, 3.0 };
    const result = try nearestRankPercentile(&values, 0.5);
    try std.testing.expectEqual(@as(f64, 4.0), result);
}
