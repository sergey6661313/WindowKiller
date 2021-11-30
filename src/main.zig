const std = @import("std");

var working: bool = true;

pub fn main() anyerror!void {
    while (working) {
        // TODO read keyboard
        // TODO find ontop window
        // TODO kill ontop window
        // TODO create tray icon with menu
        std.log.info("tick.", .{});
        working = false;
    }
}
