const std = @import("std");
const c = @import("libmtp").c;

pub fn init() void {
    c.LIBMTP_Init();
}

pub fn open() OpenError![*c]c.LIBMTP_mtpdevice_t {
    var raw: [*c]c.LIBMTP_raw_device_t = null;
    var len: c_int = 0;
    const err = c.LIBMTP_Detect_Raw_Devices(&raw, &len);
    if (err != c.LIBMTP_ERROR_NONE) {
        return error.DeviceNotFound;
    }

    const device = c.LIBMTP_Open_Raw_Device_Uncached(raw);
    if (device == null) {
        return error.OpenFailed;
    }
    return device;
}

pub fn close(device: [*c]c.LIBMTP_mtpdevice_t) void {
    c.LIBMTP_Release_Device(device);
}

pub fn init_storages(device: [*c]c.LIBMTP_mtpdevice_t) bool {
    return c.LIBMTP_Get_Storage(device, c.LIBMTP_STORAGE_SORTBY_NOTSORTED) == c.LIBMTP_ERROR_NONE;
}

pub fn files(device: [*c]c.LIBMTP_mtpdevice_t, storage_id: u32) [*c]c.LIBMTP_file_t {
    return c.LIBMTP_Get_Files_And_Folders(device, storage_id, c.LIBMTP_FILES_AND_FOLDERS_ROOT);
}

pub const OpenError = error{ DeviceNotFound, OpenFailed };
