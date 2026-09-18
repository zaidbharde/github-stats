const std = @import("std");

pub const Band = enum { low, normal, high, critical };

pub const Thresholds = struct {
    normal_min: f64,
    high_min: f64,
    critical_min: f64,

    pub fn classify(self: Thresholds, value: f64) Band {
        if (value < self.normal_min) return .low;
        if (value < self.high_min) return .normal;
        if (value < self.critical_min) return .high;
        return .critical;
    }
};

test "thresholds classify adjacent bands" {
    const thresholds = Thresholds{ .normal_min = 10, .high_min = 50, .critical_min = 90 };
    try std.testing.expectEqual(Band.low, thresholds.classify(9.9));
    try std.testing.expectEqual(Band.normal, thresholds.classify(10));
    try std.testing.expectEqual(Band.high, thresholds.classify(50));
    try std.testing.expectEqual(Band.critical, thresholds.classify(90));
}
