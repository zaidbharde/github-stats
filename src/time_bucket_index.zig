const std = @import("std");

pub const Bucket = struct {
    start: i64,
    width: i64,

    pub fn index(self: Bucket, timestamp: i64) i64 {
        if (self.width <= 0) return 0;
        const offset = timestamp - self.start;
        if (offset >= 0) return @divFloor(offset, self.width);
        return @divFloor(offset - self.width + 1, self.width);
    }

    pub fn startAt(self: Bucket, timestamp: i64) i64 {
        return self.start + self.index(timestamp) * self.width;
    }
};

test "bucket index handles timestamps before and after origin" {
    const bucket = Bucket{ .start = 100, .width = 10 };
    try std.testing.expectEqual(@as(i64, 0), bucket.index(100));
    try std.testing.expectEqual(@as(i64, 2), bucket.index(129));
    try std.testing.expectEqual(@as(i64, -1), bucket.index(99));
    try std.testing.expectEqual(@as(i64, 80), bucket.startAt(81));
}
