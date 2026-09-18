const std = @import("std");

pub const RetryPolicy = struct {
    base_ms: u64,
    cap_ms: u64,
    attempts: u8 = 0,

    pub fn nextDelay(self: *RetryPolicy) ?u64 {
        if (self.attempts >= 16) return null;
        const shift: u6 = @intCast(self.attempts);
        const multiplier = @as(u64, 1) << shift;
        const delay = @min(self.base_ms * multiplier, self.cap_ms);
        self.attempts += 1;
        return delay;
    }

    pub fn reset(self: *RetryPolicy) void {
        self.attempts = 0;
    }
};

test "retry policy caps exponential growth" {
    var policy = RetryPolicy{ .base_ms = 25, .cap_ms = 100 };
    try std.testing.expectEqual(@as(?u64, 25), policy.nextDelay());
    try std.testing.expectEqual(@as(?u64, 50), policy.nextDelay());
    try std.testing.expectEqual(@as(?u64, 100), policy.nextDelay());
    try std.testing.expectEqual(@as(?u64, 100), policy.nextDelay());
}
