const std = @import("std");

pub const Sampler = struct {
    limit: usize,
    seen: usize = 0,
    kept: usize = 0,

    pub fn init(limit: usize) Sampler {
        return .{ .limit = limit };
    }

    pub fn accept(self: *Sampler, line_number: usize) bool {
        self.seen += 1;
        if (self.kept < self.limit) {
            self.kept += 1;
            return true;
        }
        if (self.limit == 0) return false;
        const stride = self.seen / self.limit;
        return stride > 0 and line_number % stride == 0;
    }
};

test "sampler keeps an initial budget" {
    var sampler = Sampler.init(2);
    try std.testing.expect(sampler.accept(1));
    try std.testing.expect(sampler.accept(2));
    try std.testing.expect(!sampler.accept(3));
    try std.testing.expectEqual(@as(usize, 3), sampler.seen);
}
