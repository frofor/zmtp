const std = @import("std");
const zmtp = @import("zmtp");
const command = @import("command");

pub fn main() !void {
    zmtp.init();

    const device = zmtp.open() catch |e| {
        switch (e) {
            zmtp.OpenError.DeviceNotFound => std.debug.print("Device not found\n", .{}),
            zmtp.OpenError.OpenFailed => std.debug.print("Failed to open device\n", .{}),
        }
        std.process.exit(1);
    };
    defer zmtp.close(device);

    if (!zmtp.init_storages(device)) {
        std.debug.print("Allow storage access and try again\n", .{});
        std.process.exit(1);
    }

    const storage = device.*.storage;
    if (storage == null) {
        std.debug.print("Storage not found\n", .{});
        std.process.exit(1);
    }

    command.ls(device, storage.*.id);
}
