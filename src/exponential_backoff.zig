const std = @import("std");

pub const Backoff = struct {
    base_ms: u64,
    cap_ms: u64,

    pub fn delay(self: Backoff, attempt: u6) u64 {
        if (self.base_ms == 0 or self.cap_ms == 0) return 0;
        var value = self.base_ms;
        var remaining = attempt;
        while (remaining > 0 and value < self.cap_ms) : (remaining -= 1) {
            if (value > self.cap_ms / 2) return self.cap_ms;
            value *= 2;
        }
        return @min(value, self.cap_ms);
    }

    pub fn sequence(self: Backoff, attempts: usize, output: []u64) usize {
        const count = @min(attempts, output.len);
        for (output[0..count], 0..) |*slot, index| {
            slot.* = self.delay(@intCast(index));
        }
        return count;
    }
};

test "backoff doubles until the cap" {
    const backoff = Backoff{ .base_ms = 25, .cap_ms = 100 };
    var values: [5]u64 = undefined;
    try std.testing.expectEqual(@as(usize, 5), backoff.sequence(5, &values));
    try std.testing.expectEqualSlices(u64, &.{ 25, 50, 100, 100, 100 }, &values);
}

test "backoff handles zero and overflow boundaries" {
    try std.testing.expectEqual(@as(u64, 0), (Backoff{ .base_ms = 0, .cap_ms = 10 }).delay(4));
    try std.testing.expectEqual(@as(u64, 1000), (Backoff{ .base_ms = 900, .cap_ms = 1000 }).delay(5));
}
