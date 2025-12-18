const std = @import("std");
const zmtp = @import("zmtp");
const c = @import("libmtp").c;
const command = @import("command");
const Allocator = std.mem.Allocator;
const Gpa = std.heap.GeneralPurposeAllocator;
const OpenError = zmtp.OpenError;
const argsAlloc = std.process.argsAlloc;
const argsFree = std.process.argsFree;
const allocPrint = std.fmt.allocPrint;
const exit = std.process.exit;
const print = std.debug.print;
const stringToEnum = std.meta.stringToEnum;

pub fn main() !void {
    var gpa = Gpa(.{}){};
    defer _ = gpa.deinit();
    const alloc = gpa.allocator();

    const args = try argsAlloc(alloc);
    defer argsFree(alloc, args);

    if (args.len < 2) {
        printUsage();
        exit(1);
    }

    const cmd = stringToEnum(Command, args[1]) orelse {
        printErr("Unknown command: {s}", .{args[1]});
        exit(1);
    };

    zmtp.init();

    const device = zmtp.open() catch |e| {
        switch (e) {
            OpenError.DeviceNotFound => printErr("Device not found", .{}),
            OpenError.OpenFailed => printErr("Failed to open device", .{}),
        }
        exit(1);
    };
    defer zmtp.close(device);

    if (!zmtp.initStorages(device)) {
        printErr("Allow storage access and try again", .{});
        exit(1);
    }

    const storage = device.*.storage;
    if (storage == null) {
        printErr("Storage not found", .{});
        exit(1);
    }

    const folder_id = c.LIBMTP_FILES_AND_FOLDERS_ROOT;

    switch (cmd) {
        .ls => command.ls(device, storage.*.id, folder_id),
    }
}

fn printUsage() void {
    print(
        "\x1b[4m\x1b[1mUsage:\x1b[0m zmtp <COMMAND>\n" ++
            "\n" ++
            "\x1b[4m\x1b[1mCommands:\x1b[0m\n" ++
            "  ls  List files and folders\n",
        .{},
    );
}

fn printErr(comptime fmt: []const u8, args: anytype) void {
    print("\x1b[4m\x1b[1m\x1b[31mError:\x1b[0m " ++ fmt ++ "\n", args);
}

const Command = enum {
    ls,
};
