const std = @import("std");

pub const Flags = packed struct(u8) {
    archived: bool = false,
    fork: bool = false,
    private: bool = false,
    has_release: bool = false,
    has_issues: bool = false,
    has_wiki: bool = false,
    reserved: bool = false,
    selected: bool = false,

    pub fn mask(self: Flags) u8 {
        return @bitCast(self);
    }

    pub fn fromMask(value: u8) Flags {
        return @bitCast(value);
    }
};

test "round trips repository classification flags" {
    const original = Flags{ .private = true, .has_release = true, .selected = true };
    const restored = Flags.fromMask(original.mask());
    try std.testing.expect(restored.private);
    try std.testing.expect(restored.has_release);
    try std.testing.expect(restored.selected);
    try std.testing.expect(!restored.archived);
}
