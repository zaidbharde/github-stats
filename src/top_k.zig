const std = @import("std");

pub const Entry = struct {
    key: []const u8,
    score: i64,
};

pub fn insert(entries: []Entry, item: Entry) void {
    if (entries.len == 0) return;
    var position: usize = 0;
    while (position < entries.len and entries[position].score >= item.score) : (position += 1) {}
    if (position >= entries.len) return;
    var index = entries.len - 1;
    while (index > position) : (index -= 1) entries[index] = entries[index - 1];
    entries[position] = item;
}

pub fn totalScore(entries: []const Entry) i64 {
    var total: i64 = 0;
    for (entries) |entry| total += entry.score;
    return total;
}

test "keeps entries ordered and bounded" {
    var entries = [_]Entry{
        .{ .key = "old", .score = 40 },
        .{ .key = "mid", .score = 20 },
        .{ .key = "low", .score = 5 },
    };
    insert(&entries, .{ .key = "new", .score = 30 });
    try std.testing.expectEqualStrings("old", entries[0].key);
    try std.testing.expectEqualStrings("new", entries[1].key);
    try std.testing.expectEqual(@as(i64, 65), totalScore(&entries));
}
