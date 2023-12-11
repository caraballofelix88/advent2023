const std = @import("std");
const utils = @import("utils");

pub fn main() void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};

    const allocator = gpa.allocator();

    var file = "src/input.txt".*;

    if (utils.fileToString(allocator, &file)) |fileString| {
        defer allocator.free(fileString);

        const result = doThing(fileString);
        _ = result;
    } else |err| {
        std.debug.print("{}", .{err});
    }
}

const maxR = 12;
const maxG = 13;
const maxB = 14;

fn doThing(input: []u8) void {
    var total: u32 = 0;
    var lines = std.mem.split(u8, input, "\n");

    var currGame: u32 = 1;
    while (lines.next()) |line| {
        var parts = std.mem.split(u8, line, ":");

        // just gonna do line number, instead of parsing game number
        _ = parts.next().?;

        var checks = std.mem.split(u8, parts.next().?, ";");

        // if (allChecked(&checks)) {
        //     std.debug.print("Game #{} is possible\n", .{currGame});
        //     total += currGame;
        // } else {
        //     std.debug.print("Game #{} is NOT possible\n", .{currGame});
        // }

        total += getCubePower(&checks);

        currGame += 1;
    }

    std.debug.print("output is {}\n", .{total});
}

fn allChecked(iter: *std.mem.SplitIterator(u8, .sequence)) bool {
    while (iter.next()) |item| {
        if (!checkIsPossible(item)) {
            return false;
        }
    }

    return true;
}

fn getCubePower(iter: *std.mem.SplitIterator(u8, .sequence)) u32 {
    const Color = enum { red, green, blue };

    var r: u32 = 0;
    var g: u32 = 0;
    var b: u32 = 0;

    while (iter.next()) |check| {
        var counts = std.mem.split(u8, check, ",");

        while (counts.next()) |count| {
            var parts = std.mem.split(u8, count, " ");

            _ = parts.next(); // toss preceding space
            const pt1 = parts.next() orelse "blank";
            const pt2 = parts.next() orelse "blank";

            const amount = std.fmt.parseInt(u32, pt1, 10) catch 0;
            const maybeColor = std.meta.stringToEnum(Color, pt2);

            if (maybeColor) |color| {
                switch (color) {
                    .red => r = @max(amount, r),
                    .green => g = @max(amount, g),
                    .blue => b = @max(amount, b),
                }
            }
        }
    }

    return r * g * b;
}

fn checkIsPossible(checkStr: []const u8) bool {
    const Color = enum { red, green, blue };

    var r: u32 = 0;
    var g: u32 = 0;
    var b: u32 = 0;

    var counts = std.mem.split(u8, checkStr, ",");

    while (counts.next()) |count| {
        var parts = std.mem.split(u8, count, " ");

        _ = parts.next(); // toss preceding space
        const pt1 = parts.next() orelse "blank";
        const pt2 = parts.next() orelse "blank";

        const amount = std.fmt.parseInt(u32, pt1, 10) catch 0;
        const maybeColor = std.meta.stringToEnum(Color, pt2);

        if (maybeColor) |color| {
            switch (color) {
                .red => r = amount,
                .green => g = amount,
                .blue => b = amount,
            }
        }
    }

    const isValid = (r <= maxR and g <= maxG and b <= maxB);

    std.debug.print("\t check - R: {}, G: {}, B: {} ", .{ r, g, b });

    if (isValid) {
        std.debug.print("\n", .{});
    } else {
        std.debug.print(" -- INVALID \n", .{});
    }

    return isValid;
}
