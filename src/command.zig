const std = @import("std");
const zmtp = @import("zmtp");
const c = @import("libmtp").c;
const ui = @import("ui");
const Allocator = std.mem.Allocator;
const File = std.fs.File;
const Reader = std.fs.File.Reader;
const Writer = std.fs.File.Writer;
const allocPrint = std.fmt.allocPrint;
const exit = std.process.exit;
const print = std.debug.print;
const stringToEnum = std.meta.stringToEnum;

pub fn shell(
    alloc: Allocator,
    device: [*c]c.LIBMTP_mtpdevice_t,
    storage_id: u32,
    folder_id: u32,
) !void {
    var stdin_buf: [1024]u8 = undefined;
    var stdin = File.stdin().readerStreaming(&stdin_buf);
    const reader = &stdin.interface;

    var stdout_buf: [256]u8 = undefined;
    var stdout = File.stdout().writer(&stdout_buf);
    const writer = &stdout.interface;

    var storage = device.*.storage;
    while (storage.*.id != storage_id) {
        storage = storage.*.next;
    }

    while (true) {
        const prompt = try allocPrint(alloc, "[{s}]# ", .{storage.*.StorageDescription});
        try writer.writeAll(prompt);
        try writer.flush();

        const input = try reader.takeDelimiterExclusive('\n');
        reader.tossBuffered();

        if (input.len == 0) {
            continue;
        }

        const cmd = stringToEnum(ShellCommand, input) orelse {
            ui.drawErr("Unknown command: {s}", .{input});
            continue;
        };

        switch (cmd) {
            .help => ui.drawShellHelp(),
            .ls => ls(device, storage.*.id, folder_id),
            .exit => exit(0),
        }
    }
}

pub fn ls(device: [*c]c.LIBMTP_mtpdevice_t, storage_id: u32, folder_id: u32) void {
    var file = zmtp.files(device, storage_id, folder_id);
    while (file != null) {
        print("{s}\n", .{file.*.filename});
        file = file.*.next;
    }
}

pub const Command = enum {
    help,
    shell,
    ls,
};

const ShellCommand = enum {
    help,
    ls,
    exit,
};
