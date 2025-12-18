const std = @import("std");
const zmtp = @import("zmtp");
const c = @import("libmtp").c;
const command = @import("command");
const ui = @import("ui");
const Allocator = std.mem.Allocator;
const Command = command.Command;
const Gpa = std.heap.GeneralPurposeAllocator;
const OpenError = zmtp.OpenError;
const argsAlloc = std.process.argsAlloc;
const argsFree = std.process.argsFree;
const exit = std.process.exit;
const stringToEnum = std.meta.stringToEnum;

pub fn main() !void {
    var gpa = Gpa(.{}){};
    defer _ = gpa.deinit();
    const alloc = gpa.allocator();

    const args = try argsAlloc(alloc);
    defer argsFree(alloc, args);

    if (args.len < 2) {
        ui.drawHelp();
        exit(0);
    }

    const cmd = stringToEnum(Command, args[1]) orelse {
        ui.drawErr("Unknown command: {s}", .{args[1]});
        exit(1);
    };

    if (cmd == .help) {
        ui.drawHelp();
        exit(0);
    }

    zmtp.init();

    const device = zmtp.open() catch |e| {
        switch (e) {
            OpenError.DeviceNotFound => ui.drawErr("Device not found", .{}),
            OpenError.OpenFailed => ui.drawErr("Failed to open device", .{}),
        }
        exit(1);
    };
    defer zmtp.close(device);

    if (!zmtp.initStorages(device)) {
        ui.drawErr("Allow storage access and try again", .{});
        exit(1);
    }

    const storage = device.*.storage;
    if (storage == null) {
        ui.drawErr("Storage not found", .{});
        exit(1);
    }

    const folder_id = c.LIBMTP_FILES_AND_FOLDERS_ROOT;

    switch (cmd) {
        .shell => try command.shell(alloc, device, storage.*.id, folder_id),
        .ls => command.ls(device, storage.*.id, folder_id),
        else => {},
    }
}
