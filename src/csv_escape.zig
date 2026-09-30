const std = @import("std");

pub fn needsQuotes(field: []const u8) bool {
    return std.mem.indexOfAny(u8, field, ",\"\r\n") != null;
}

pub fn escapedLength(field: []const u8) usize {
    var length = field.len;
    if (!needsQuotes(field)) return length;
    for (field) |character| if (character == '"') length += 1;
    return length + 2;
}

pub fn write(field: []const u8, output: []u8) !usize {
    const required = escapedLength(field);
    if (output.len < required) return error.NoSpaceLeft;
    if (!needsQuotes(field)) {
        @memcpy(output[0..field.len], field);
        return field.len;
    }
    var cursor: usize = 0;
    output[cursor] = '"';
    cursor += 1;
    for (field) |character| {
        if (character == '"') {
            output[cursor] = '"';
            cursor += 1;
        }
        output[cursor] = character;
        cursor += 1;
    }
    output[cursor] = '"';
    return cursor + 1;
}

test "csv escaping quotes fields only when needed" {
    var output: [32]u8 = undefined;
    const plain = try write("alpha", &output);
    try std.testing.expectEqualStrings("alpha", output[0..plain]);
    const quoted = try write("a,b\"c", &output);
    try std.testing.expectEqualStrings("\"a,b\"\"c\"", output[0..quoted]);
}
