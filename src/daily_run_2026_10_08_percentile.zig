const std = @import("std");

pub const Percentile = struct {
    allocator: std.mem.Allocator,
    samples: std.ArrayList(f64),

    pub fn init(allocator: std.mem.Allocator) Percentile {
        return .{ .allocator = allocator, .samples = std.ArrayList(f64).init(allocator) };
    }

    pub fn deinit(self: *Percentile) void {
        self.samples.deinit();
    }

    pub fn add(self: *Percentile, value: f64) !void {
        try self.samples.append(value);
    }

    pub fn value(self: *Percentile, fraction: f64) ?f64 {
        if (self.samples.items.len == 0 or fraction < 0 or fraction > 1) return null;
        std.sort.block(f64, self.samples.items, {}, comptime std.sort.asc(f64));
        const position = fraction * @as(f64, @floatFromInt(self.samples.items.len - 1));
        const lower = @as(usize, @intFromFloat(@floor(position)));
        const upper = @as(usize, @intFromFloat(@ceil(position)));
        if (lower == upper) return self.samples.items[lower];
        const weight = position - @as(f64, @floatFromInt(lower));
        return self.samples.items[lower] * (1 - weight) + self.samples.items[upper] * weight;
    }
};

pub fn main() !void {
    var estimator = Percentile.init(std.heap.page_allocator);
    defer estimator.deinit();
    try estimator.add(10);
    try estimator.add(20);
    try estimator.add(40);
    std.debug.assert(estimator.value(0.5).? == 20);
}
