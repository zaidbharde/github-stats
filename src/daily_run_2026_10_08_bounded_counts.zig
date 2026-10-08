const std = @import("std");

pub const BoundedCounts = struct {
    allocator: std.mem.Allocator,
    capacity: usize,
    values: std.StringHashMap(u64),

    pub fn init(allocator: std.mem.Allocator, capacity: usize) BoundedCounts {
        return .{ .allocator = allocator, .capacity = capacity, .values = std.StringHashMap(u64).init(allocator) };
    }

    pub fn deinit(self: *BoundedCounts) void {
        self.values.deinit();
    }

    pub fn add(self: *BoundedCounts, key: []const u8, amount: u64) !void {
        if (self.values.count() == self.capacity and !self.values.contains(key)) {
            var iterator = self.values.iterator();
            if (iterator.next()) |oldest| _ = self.values.remove(oldest.key_ptr.*);
        }
        const entry = try self.values.getOrPut(key);
        if (!entry.found_existing) entry.value_ptr.* = 0;
        entry.value_ptr.* += amount;
    }

    pub fn get(self: *const BoundedCounts, key: []const u8) u64 {
        return self.values.get(key) orelse 0;
    }
};

pub fn main() !void {
    var counts = BoundedCounts.init(std.heap.page_allocator, 2);
    defer counts.deinit();
    try counts.add("green", 3);
    try counts.add("blue", 2);
    try counts.add("green", 4);
    std.debug.assert(counts.get("green") == 7);
}
