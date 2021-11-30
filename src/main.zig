const std = @import("std");
pub const c = @cImport({
    // canonical c
    @cInclude("stdio.h");
    @cInclude("stdlib.h");

    // winapi
    @cDefine("WIN32_LEAN_AND_MEAN", "1");
    @cInclude("windows.h");
});

var working: bool = true;
var count: usize = 0;

pub fn main() anyerror!void {
    std.log.info("Hello!", .{});

    while (working) {
        // TODO read keyboard
        var tabKeyState = c.GetAsyncKeyState('p');
        std.log.info("tabKeyState = {}", .{tabKeyState});
        // TODO find ontop window
        // TODO kill ontop window
        if(count == 3) std.log.info("here we are", .{});
        std.time.sleep(std.time.ns_per_ms * 100);
        //working = false;
    }

    std.log.info("Bye!", .{});
}
