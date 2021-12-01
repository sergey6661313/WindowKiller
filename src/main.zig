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
var last_time: c_ulong = 0;
var times: [3]c_ulong = .{1000}**3;
var pos: u8 = 0;
var hook: c.HHOOK = undefined;
const key = 80;

fn Keyboard_Proc(nCode: c_int, wParam: c_ulonglong, lParam: c_longlong) callconv(.C) c_longlong {
    const lParam_as_usize = @intCast(usize, lParam);
    const ptr_hook_struct = @intToPtr(*c.KBDLLHOOKSTRUCT, lParam_as_usize);

    if (ptr_hook_struct.vkCode == key) { // совпадает номер клавиши
    if (wParam % 2 == 1) {               // клавиша нажата
        const current_time = ptr_hook_struct.time;
        pos = (pos + 1) % 3;
        times[pos] = current_time - last_time;
        last_time = current_time;

        if(times[0] + times[1] + times[2] < 1500) {
            const window = c.GetForegroundWindow();
            std.log.info("window = {x}", .{@ptrToInt(window)});
            _ = c.EndTask(window, 0, 1);
        }
    }}
    return c.CallNextHookEx(null, nCode, wParam, lParam);
}

pub fn main() anyerror!void {
    //var hInstance = c.GetModuleHandleW(null);
    hook = c.SetWindowsHookExW(c.WH_KEYBOARD_LL, Keyboard_Proc, null, 0);
    _ = c.MessageBoxA(0, "please NOT press ok. for kill windows just press button p tree times", "warnong", 0);
}
