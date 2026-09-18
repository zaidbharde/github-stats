const std = @import("std");

pub const Bucket = struct {
    start: i64,
    width: i64,

    pub fn index(self: Bucket, timestamp: i64) i64 {
        if (self.width <= 0) return 0;
        const offset = timestamp - self.start;
        return @divFloor(offset, self.width);
    }

    pub fn startAt(self: Bucket, bucket_index: i64) i64 {
        return self.start + bucket_index * self.width;
    }

    pub fn contains(self: Bucket, timestamp: i64, bucket_index: i64) bool {
        const begin = self.startAt(bucket_index);
        return timestamp >= begin and timestamp < begin + self.width;
    }
};

test "bucket handles timestamps before the origin" {
    const bucket = Bucket{ .start = 100, .width = 60 };
    try std.testing.expectEqual(@as(i64, -1), bucket.index(99));
    try std.testing.expectEqual(@as(i64, -2), bucket.index(0));
    try std.testing.expect(bucket.contains(100, 0));
    try std.testing.expect(!bucket.contains(160, 0));
}
