const std = @import("std");

pub const Label = struct { name: []const u8, value: []const u8 };

pub fn parse(input: []const u8, output: []Label) !usize {
    var count: usize = 0;
    var cursor: usize = 0;
    while (cursor < input.len) {
        if (count == output.len) return error.TooManyLabels;
        const equals = std.mem.indexOfScalarPos(u8, input, cursor, '=') orelse return error.MissingEquals;
        const comma = std.mem.indexOfScalarPos(u8, input, equals + 1, ',') orelse input.len;
        if (equals == cursor or comma == equals + 1) return error.EmptyLabelPart;
        output[count] = .{ .name = input[cursor..equals], .value = input[equals + 1 .. comma] };
        count += 1;
        cursor = if (comma == input.len) input.len else comma + 1;
    }
    return count;
}

test "parses labels without allocating" {
    var labels: [3]Label = undefined;
    const count = try parse("host=api,region=eu,role=worker", &labels);
    try std.testing.expectEqual(@as(usize, 3), count);
    try std.testing.expectEqualStrings("region", labels[1].name);
    try std.testing.expectEqualStrings("eu", labels[1].value);
}
