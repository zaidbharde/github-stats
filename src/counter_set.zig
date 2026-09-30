const std = @import("std");

pub const CounterSet = struct {
    names: [16][]const u8 = undefined,
    values: [16]u64 = [_]u64{0} ** 16,
    length: usize = 0,

    pub fn increment(self: *CounterSet, name: []const u8, amount: u64) bool {
        for (self.names[0..self.length], 0..) |known, index| {
            if (std.mem.eql(u8, known, name)) {
                self.values[index] += amount;
                return true;
            }
        }
        if (self.length == self.names.len) return false;
        self.names[self.length] = name;
        self.values[self.length] = amount;
        self.length += 1;
        return true;
    }

    pub fn value(self: CounterSet, name: []const u8) ?u64 {
        for (self.names[0..self.length], 0..) |known, index| {
            if (std.mem.eql(u8, known, name)) return self.values[index];
        }
        return null;
    }
};

test "counter set aggregates repeated labels" {
    var counters = CounterSet{};
    try std.testing.expect(counters.increment("ok", 2));
    try std.testing.expect(counters.increment("ok", 3));
    try std.testing.expect(counters.increment("failed", 1));
    try std.testing.expectEqual(@as(?u64, 5), counters.value("ok"));
    try std.testing.expectEqual(@as(?u64, 1), counters.value("failed"));
    try std.testing.expect(counters.value("missing") == null);
}
