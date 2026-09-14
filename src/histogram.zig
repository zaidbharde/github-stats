const std = @import("std");

pub const Histogram = struct {
    bins: []u64,
    minimum: i64,
    width: u64,

    pub fn init(bins: []u64, minimum: i64, width: u64) Histogram {
        std.debug.assert(width > 0);
        @memset(bins, 0);
        return .{ .bins = bins, .minimum = minimum, .width = width };
    }

    pub fn add(self: *Histogram, value: i64) void {
        if (value < self.minimum) return;
        const offset = @as(u64, @intCast(value - self.minimum));
        const index = offset / self.width;
        if (index < self.bins.len) self.bins[index] += 1;
    }

    pub fn total(self: Histogram) u64 {
        var count: u64 = 0;
        for (self.bins) |bin| count += bin;
        return count;
    }
};

test "counts values in bounded bins" {
    var bins = [_]u64{ 0, 0, 0 };
    var histogram = Histogram.init(&bins, 0, 10);
    for ([_]i64{ 1, 9, 10, 25, 80 }) |value| histogram.add(value);
    try std.testing.expectEqual(@as(u64, 4), histogram.total());
    try std.testing.expectEqual(@as(u64, 2), bins[0]);
}
