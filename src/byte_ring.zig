const std = @import("std");

pub const ByteRing = struct {
    data: []u8,
    head: usize = 0,
    len: usize = 0,

    pub fn init(data: []u8) ByteRing {
        return .{ .data = data };
    }

    pub fn append(self: *ByteRing, value: u8) void {
        if (self.data.len == 0) return;
        const position = (self.head + self.len) % self.data.len;
        self.data[position] = value;
        if (self.len < self.data.len) {
            self.len += 1;
        } else {
            self.head = (self.head + 1) % self.data.len;
        }
    }

    pub fn at(self: ByteRing, index: usize) ?u8 {
        if (index >= self.len) return null;
        return self.data[(self.head + index) % self.data.len];
    }
};

test "ring retains the newest bytes" {
    var storage: [3]u8 = undefined;
    var ring = ByteRing.init(&storage);
    ring.append('a');
    ring.append('b');
    ring.append('c');
    ring.append('d');
    try std.testing.expectEqual(@as(?u8, 'b'), ring.at(0));
    try std.testing.expectEqual(@as(?u8, 'd'), ring.at(2));
}
