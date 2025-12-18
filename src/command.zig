const std = @import("std");
const zmtp = @import("zmtp");
const c = @import("libmtp").c;

pub fn ls(device: [*c]c.LIBMTP_mtpdevice_t, storage_id: u32) void {
    var file = zmtp.files(device, storage_id);
    while (file != null) {
        std.debug.print("{s}\n", .{file.*.filename});
        file = file.*.next;
    }
}
