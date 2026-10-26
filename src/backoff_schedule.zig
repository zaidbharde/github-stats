const std = @import("std");

pub const Schedule = struct {
    base_ms: u64,
    cap_ms: u64,

    pub fn delay(self: Schedule, attempt: u32) u64 {
        var value = self.base_ms;
        var step: u32 = 0;
        while (step < attempt and value < self.cap_ms) : (step += 1) {
            value = if (value > self.cap_ms / 2) self.cap_ms else value * 2;
        }
        return @min(value, self.cap_ms);
    }
};

pub fn total(schedule: Schedule, retries: u32) u64 {
    var sum: u64 = 0;
    var attempt: u32 = 0;
    while (attempt < retries) : (attempt += 1) sum += schedule.delay(attempt);
    return sum;
}

test "doubles delays until reaching the cap" {
    const schedule = Schedule{ .base_ms = 250, .cap_ms = 1_000 };
    try std.testing.expectEqual(@as(u64, 250), schedule.delay(0));
    try std.testing.expectEqual(@as(u64, 500), schedule.delay(1));
    try std.testing.expectEqual(@as(u64, 1_000), schedule.delay(2));
    try std.testing.expectEqual(@as(u64, 2_750), total(schedule, 4));
}
