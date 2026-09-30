const std = @import("std");

pub fn BoundedQueue(comptime T: type, comptime capacity: usize) type {
    return struct {
        items: [capacity]T = undefined,
        head: usize = 0,
        length: usize = 0,

        pub fn push(self: *@This(), value: T) bool {
            if (self.length == capacity) return false;
            const index = (self.head + self.length) % capacity;
            self.items[index] = value;
            self.length += 1;
            return true;
        }

        pub fn pop(self: *@This()) ?T {
            if (self.length == 0) return null;
            const value = self.items[self.head];
            self.head = (self.head + 1) % capacity;
            self.length -= 1;
            return value;
        }

        pub fn count(self: @This()) usize {
            return self.length;
        }
    };
}

test "bounded queue preserves FIFO order after wraparound" {
    var queue = BoundedQueue(u8, 3){};
    try std.testing.expect(queue.push(10));
    try std.testing.expect(queue.push(20));
    try std.testing.expectEqual(@as(?u8, 10), queue.pop());
    try std.testing.expect(queue.push(30));
    try std.testing.expect(queue.push(40));
    try std.testing.expect(!queue.push(50));
    try std.testing.expectEqual(@as(?u8, 20), queue.pop());
    try std.testing.expectEqual(@as(?u8, 30), queue.pop());
    try std.testing.expectEqual(@as(?u8, 40), queue.pop());
    try std.testing.expectEqual(@as(usize, 0), queue.count());
}
