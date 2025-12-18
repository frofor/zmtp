const std = @import("std");
const zmtp = @import("zmtp");
const c = @import("libmtp").c;
const print = std.debug.print;

pub fn ls(device: [*c]c.LIBMTP_mtpdevice_t, storage_id: u32, folder_id: u32) void {
    var file = zmtp.files(device, storage_id, folder_id);
    while (file != null) {
        print("{s}\n", .{file.*.filename});
        file = file.*.next;
    }
}
