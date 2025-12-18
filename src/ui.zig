const std = @import("std");
pub const print = std.debug.print;

pub fn drawShellHelp() void {
    print(
        "\x1b[4m\x1b[1mUsage:\x1b[0m <COMMAND>\n" ++
            "\n" ++
            "\x1b[4m\x1b[1mCommands:\x1b[0m\n" ++
            "  help  Print usage information\n" ++
            "  ls    List files and folders\n" ++
            "  exit  Exit shell\n",
        .{},
    );
}

pub fn drawHelp() void {
    print(
        "\x1b[4m\x1b[1mUsage:\x1b[0m zmtp <COMMAND>\n" ++
            "\n" ++
            "\x1b[4m\x1b[1mCommands:\x1b[0m\n" ++
            "  help   Print usage information\n" ++
            "  shell  Enter interactive shell\n" ++
            "  ls     List files and folders\n",
        .{},
    );
}

pub fn drawErr(comptime fmt: []const u8, args: anytype) void {
    print("\x1b[4m\x1b[1m\x1b[31mError:\x1b[0m " ++ fmt ++ "\n", args);
}
