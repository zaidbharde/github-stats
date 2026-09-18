const std = @import("std");

pub const RollingCounter = struct {
    values: []u64,
    cursor: usize = 0,
    total: u64 = 0,

    pub fn init(values: []u64) RollingCounter {
        @memset(values, 0);
        return .{ .values = values };
    }

    pub fn add(self: *RollingCounter, value: u64) void {
        if (self.values.len == 0) return;
        self.total -= self.values[self.cursor];
        self.values[self.cursor] = value;
        self.total += value;
        self.cursor = (self.cursor + 1) % self.values.len;
    }

    pub fn sum(self: RollingCounter) u64 {
        return self.total;
    }

    pub fn average(self: RollingCounter) f64 {
        if (self.values.len == 0) return 0;
        return @as(f64, @floatFromInt(self.total)) / @as(f64, @floatFromInt(self.values.len));
    }
};

test "rolling counter replaces the oldest sample" {
    var slots: [3]u64 = undefined;
    var counter = RollingCounter.init(&slots);
    counter.add(4);
    counter.add(7);
    counter.add(9);
    counter.add(2);
    try std.testing.expectEqual(@as(u64, 18), counter.sum());
    try std.testing.expectApproxEqAbs(@as(f64, 6), counter.average(), 0.001);
}
