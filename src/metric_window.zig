const std = @import("std");

pub const MetricWindow = struct {
    samples: []f64,
    next: usize = 0,
    count: usize = 0,

    pub fn init(samples: []f64) MetricWindow {
        return .{ .samples = samples };
    }

    pub fn push(self: *MetricWindow, value: f64) void {
        if (self.samples.len == 0) return;
        self.samples[self.next] = value;
        self.next = (self.next + 1) % self.samples.len;
        if (self.count < self.samples.len) self.count += 1;
    }

    pub fn mean(self: MetricWindow) f64 {
        if (self.count == 0) return 0;
        var total: f64 = 0;
        for (self.samples[0..self.count]) |sample| total += sample;
        return total / @as(f64, @floatFromInt(self.count));
    }
};

test "window mean uses only populated samples" {
    var storage: [4]f64 = undefined;
    var window = MetricWindow.init(&storage);
    window.push(2.0);
    window.push(6.0);
    try std.testing.expectApproxEqAbs(@as(f64, 4.0), window.mean(), 0.001);
}
