const std = @import("std");
const testing = std.testing;
const expect = testing.expect;

const EOF: u8 = 0x03;

// opens a file and returns a buffer pointer
pub fn fileToString(allocator: std.mem.Allocator, dir: []u8) ![]u8 {
    var file = try std.fs.cwd().openFile(dir, .{});
    defer file.close();

    var buffer = std.io.bufferedReader(file.reader());
    var reader = buffer.reader();

    var arr = std.ArrayList(u8).init(allocator);

    reader.streamUntilDelimiter(arr.writer(), EOF, null) catch {};

    return arr.toOwnedSlice();
}
