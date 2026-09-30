const std = @import("std");

pub fn LruCache(comptime K: type, comptime V: type, comptime capacity: usize) type {
    return struct {
        const Entry = struct { key: K, value: V, age: u64 };
        entries: [capacity]?Entry = [_]?Entry{null} ** capacity,
        clock: u64 = 0,

        pub fn put(self: *@This(), key: K, value: V) void {
            self.clock += 1;
            var oldest: usize = 0;
            for (self.entries, 0..) |entry, index| {
                if (entry) |item| {
                    if (std.meta.eql(item.key, key)) {
                        self.entries[index] = .{ .key = key, .value = value, .age = self.clock };
                        return;
                    }
                    if (self.entries[oldest].?.age > item.age) oldest = index;
                } else {
                    self.entries[index] = .{ .key = key, .value = value, .age = self.clock };
                    return;
                }
            }
            self.entries[oldest] = .{ .key = key, .value = value, .age = self.clock };
        }

        pub fn get(self: *@This(), key: K) ?V {
            for (&self.entries) |*entry| if (entry.*) |*item| {
                if (std.meta.eql(item.key, key)) {
                    self.clock += 1;
                    item.age = self.clock;
                    return item.value;
                }
            };
            return null;
        }
    };
}

test "lru cache evicts the least recently used entry" {
    var cache = LruCache(u8, []const u8, 2){};
    cache.put(1, "one");
    cache.put(2, "two");
    _ = cache.get(1);
    cache.put(3, "three");
    try std.testing.expectEqualStrings("one", cache.get(1).?);
    try std.testing.expect(cache.get(2) == null);
    try std.testing.expectEqualStrings("three", cache.get(3).?);
}
