const std = @import("std");

pub const ByteQueue = struct {
    storage: []u8,
    head: usize = 0,
    length: usize = 0,

    pub fn init(storage: []u8) ByteQueue {
        return .{ .storage = storage };
    }

    pub fn push(self: *ByteQueue, value: u8) bool {
        if (self.length == self.storage.len) return false;
        const index = (self.head + self.length) % self.storage.len;
        self.storage[index] = value;
        self.length += 1;
        return true;
    }

    pub fn pop(self: *ByteQueue) ?u8 {
        if (self.length == 0) return null;
        const value = self.storage[self.head];
        self.head = (self.head + 1) % self.storage.len;
        self.length -= 1;
        return value;
    }
};

test "wraps while preserving FIFO order" {
    var bytes = [_]u8{ 0, 0, 0 };
    var queue = ByteQueue.init(&bytes);
    try std.testing.expect(queue.push('a'));
    try std.testing.expect(queue.push('b'));
    try std.testing.expectEqual(@as(?u8, 'a'), queue.pop());
    try std.testing.expect(queue.push('c'));
    try std.testing.expectEqual(@as(?u8, 'b'), queue.pop());
    try std.testing.expectEqual(@as(?u8, 'c'), queue.pop());
    try std.testing.expectEqual(@as(?u8, null), queue.pop());
}
