const std = @import("std");

pub const TokenBucket = struct {
    capacity: f64,
    refill_per_second: f64,
    tokens: f64,
    last_ns: u64,

    pub fn init(capacity: f64, refill_per_second: f64, now_ns: u64) TokenBucket {
        std.debug.assert(capacity > 0 and refill_per_second > 0);
        return .{ .capacity = capacity, .refill_per_second = refill_per_second, .tokens = capacity, .last_ns = now_ns };
    }

    pub fn take(self: *TokenBucket, requested: f64, now_ns: u64) bool {
        if (requested <= 0) return false;
        self.refill(now_ns);
        if (self.tokens < requested) return false;
        self.tokens -= requested;
        return true;
    }

    pub fn available(self: *TokenBucket, now_ns: u64) f64 {
        self.refill(now_ns);
        return self.tokens;
    }

    fn refill(self: *TokenBucket, now_ns: u64) void {
        if (now_ns <= self.last_ns) return;
        const elapsed = @as(f64, @floatFromInt(now_ns - self.last_ns)) / 1_000_000_000.0;
        self.tokens = @min(self.capacity, self.tokens + elapsed * self.refill_per_second);
        self.last_ns = now_ns;
    }
};

pub fn main() void {
    var bucket = TokenBucket.init(4, 2, 0);
    std.debug.assert(bucket.take(4, 0));
    std.debug.assert(!bucket.take(1, 0));
    std.debug.assert(bucket.take(1, 500_000_000));
}
