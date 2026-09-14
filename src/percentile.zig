const std = @import("std");

pub fn percentile(sorted: []const f64, rank: f64) ?f64 {
    if (sorted.len == 0 or rank < 0 or rank > 100) return null;
    if (sorted.len == 1) return sorted[0];
    const position = rank / 100.0 * @as(f64, @floatFromInt(sorted.len - 1));
    const lower: usize = @intFromFloat(@floor(position));
    const upper = @min(lower + 1, sorted.len - 1);
    const fraction = position - @as(f64, @floatFromInt(lower));
    return sorted[lower] + (sorted[upper] - sorted[lower]) * fraction;
}

test "interpolates percentile between observations" {
    const values = [_]f64{ 10, 20, 30, 40 };
    try std.testing.expectApproxEqAbs(@as(f64, 25), percentile(&values, 50).?, 0.0001);
    try std.testing.expectApproxEqAbs(@as(f64, 10), percentile(&values, 0).?, 0.0001);
}
