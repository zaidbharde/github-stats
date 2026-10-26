const std = @import("std");

pub const RollingAverage = struct {
    values: []i64,
    next: usize = 0,
    count: usize = 0,
    sum: i64 = 0,

    pub fn init(values: []i64) RollingAverage {
        return .{ .values = values };
    }

    pub fn add(self: *RollingAverage, value: i64) void {
        if (self.values.len == 0) return;
        if (self.count == self.values.len) self.sum -= self.values[self.next] else self.count += 1;
        self.values[self.next] = value;
        self.sum += value;
        self.next = (self.next + 1) % self.values.len;
    }

    pub fn average(self: RollingAverage) ?f64 {
        if (self.count == 0) return null;
        return @as(f64, @floatFromInt(self.sum)) / @as(f64, @floatFromInt(self.count));
    }
};

test "replaces the oldest sample after filling" {
    var storage = [_]i64{ 0, 0, 0 };
    var average = RollingAverage.init(&storage);
    average.add(3);
    average.add(6);
    average.add(9);
    average.add(12);
    try std.testing.expectEqual(@as(f64, 9), average.average().?);
}
