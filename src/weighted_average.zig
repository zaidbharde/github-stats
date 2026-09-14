const std = @import("std");

pub const Sample = struct { value: f64, weight: f64 };

pub fn calculate(samples: []const Sample) ?f64 {
    if (samples.len == 0) return null;
    var weighted: f64 = 0;
    var total_weight: f64 = 0;
    for (samples) |sample| {
        if (sample.weight < 0) return null;
        weighted += sample.value * sample.weight;
        total_weight += sample.weight;
    }
    if (total_weight == 0) return null;
    return weighted / total_weight;
}

test "computes weighted average" {
    const samples = [_]Sample{ .{ .value = 10, .weight = 1 }, .{ .value = 20, .weight = 3 } };
    try std.testing.expectApproxEqAbs(@as(f64, 17.5), calculate(&samples).?, 0.0001);
}

test "rejects zero or negative weights" {
    const zero = [_]Sample{.{ .value = 4, .weight = 0 }};
    try std.testing.expect(calculate(&zero) == null);
}
