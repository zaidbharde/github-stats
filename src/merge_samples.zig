const std = @import("std");

pub fn merge(left: []const i64, right: []const i64, output: []i64) !usize {
    if (output.len < left.len + right.len) return error.OutputTooSmall;
    var a: usize = 0;
    var b: usize = 0;
    var index: usize = 0;
    while (a < left.len or b < right.len) : (index += 1) {
        if (b == right.len or (a < left.len and left[a] <= right[b])) {
            output[index] = left[a];
            a += 1;
        } else {
            output[index] = right[b];
            b += 1;
        }
    }
    return index;
}

test "merges equal values stably" {
    const left = [_]i64{ 1, 4, 8 };
    const right = [_]i64{ 2, 4, 9 };
    var output: [6]i64 = undefined;
    const length = try merge(&left, &right, &output);
    try std.testing.expectEqual(@as(usize, 6), length);
    try std.testing.expectEqualSlices(i64, &[_]i64{ 1, 2, 4, 4, 8, 9 }, output[0..length]);
}
