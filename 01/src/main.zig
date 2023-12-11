const std = @import("std");
const utils = @import("utils");

pub fn main() void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};

    const allocator = gpa.allocator();

    var file = "src/input.txt".*;

    if (utils.fileToString(allocator, &file)) |fileString| {
        defer allocator.free(fileString);

        getCalibrationValues(fileString);
    } else |err| {
        std.debug.print("{}", .{err});
    }
}

fn getDigit(char: u8) !u8 {
    return switch (char) {
        '0'...'9' => char - '0',
        else => return error.InvalidValue,
    };
}

fn getDigitWord(slice: []const u8) !u8 {
    const DigitCase = enum(u8) { zero = 0, one = 1, two = 2, three = 3, four = 4, five = 5, six = 6, seven = 7, eight = 8, nine = 9 };

    // go through possible digit word lengths and compare current slice w enum strings
    for (3..6) |wordSize| {
        if (slice.len >= wordSize) {
            const maybeDigit = std.meta.stringToEnum(DigitCase, slice[0..wordSize]);
            if (maybeDigit) |digit| {
                std.debug.print("\t got digitWord: {}\n", .{digit});

                return @intFromEnum(digit);
            }
        }
    }

    return error.InvalidValue;
}

fn getCalibrationValues(input: []u8) void {
    var total: u32 = 0;

    var lines = std.mem.split(u8, input, "\n");
    var lineNum: u32 = 0;
    while (lines.next()) |line| {
        var first: ?u8 = null;
        var last: u8 = 0;

        for (0..line.len) |idx| {
            if (getDigit(line[idx])) |val| {
                if (first == null) {
                    first = val;
                }
                last = val;
            } else |_| {}

            if (getDigitWord(line[idx..])) |val| {
                if (first == null) {
                    first = val;
                }
                last = val;
            } else |_| {}
        }

        const rowVal = ((first orelse 0) * 10) + last;

        total += rowVal;
        lineNum += 1;
        std.debug.print("line #{}: {}\n", .{ lineNum, rowVal });
    }
    std.debug.print("output is {}\n", .{total});
}
