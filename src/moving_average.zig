const std = @import("std");

pub const MovingAverage = struct {
    value: f64 = 0,
    samples: usize = 0,

    pub fn add(self: *MovingAverage, sample: f64) f64 {
        self.samples += 1;
        self.value += (sample - self.value) / @as(f64, @floatFromInt(self.samples));
        return self.value;
    }

    pub fn addMany(self: *MovingAverage, samples: []const f64) f64 {
        for (samples) |sample| _ = self.add(sample);
        return self.value;
    }

    pub fn reset(self: *MovingAverage) void {
        self.value = 0;
        self.samples = 0;
    }
};

test "moving average does not lose precision to large totals" {
    var average = MovingAverage{};
    try std.testing.expectApproxEqAbs(@as(f64, 10), average.addMany(&.{ 8, 10, 12 }), 0.000001);
    try std.testing.expectEqual(@as(usize, 3), average.samples);
    average.reset();
    try std.testing.expectEqual(@as(usize, 0), average.samples);
    try std.testing.expectApproxEqAbs(@as(f64, 7.5), average.add(7.5), 0.000001);
}
