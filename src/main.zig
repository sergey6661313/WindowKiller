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
var times: [3]c_ulong = .{0}**3;
var times_pos: u8 = 0;
var hook: c.HHOOK = undefined;
const key = 80;
var desktop_rect: c.RECT = undefined;

pub fn cmp(a: []u8, b: []u8) enum { equal, various } {
    if (a.len != a.len) return .various;
    var pos: usize = 0;
    const last = a.len - 1;
    while (true) {
        if (a[pos] != b[pos]) return .various;
        if (pos == last) return .equal;
        pos += 1;
    }
}


fn EnumWindowsProc(win: *allowzero c.struct_HWND__, lParam: c_longlong) callconv(.C) c_int {
    _ = lParam;
    var appBounds: c.RECT = undefined;

    if(c.IsWindowVisible(win) > 0) 
    if(win != c.GetDesktopWindow())
    if(win != c.GetShellWindow())
    {
        _ = c.GetWindowRect(win, &appBounds);
        const a = @ptrCast(*[@sizeOf(c.RECT)]u8, &appBounds)[0 ..];
        const b = @ptrCast(*[@sizeOf(c.RECT)]u8, &desktop_rect)[0 ..];
        if(cmp(a, b) == .equal) {
            //_ = c.CloseWindow(win);
            _ = c.EndTask(win, 0, 1);
        }
    };
    return 1;
}

fn Keyboard_Proc(nCode: c_int, wParam: c_ulonglong, lParam: c_longlong) callconv(.C) c_longlong {
    const lParam_as_usize = @intCast(usize, lParam);
    const ptr_hook_struct = @intToPtr(*c.KBDLLHOOKSTRUCT, lParam_as_usize);

    if (ptr_hook_struct.vkCode == key) { // совпадает номер клавиши
    if (wParam & 1 == 1) {               // клавиша нажата
        const current_time = ptr_hook_struct.time;
        times[times_pos] = current_time;
        times_pos = (times_pos + 1) % 3;

        _ = c.GetWindowRect(c.GetDesktopWindow(), &desktop_rect);
        if(current_time - times[times_pos] < 1500) {
            std.log.info("Hello ",.{});
            _ = c.EnumWindows(EnumWindowsProc, 0);
        }
    }}
    return c.CallNextHookEx(null, nCode, wParam, lParam);
}

pub fn main() anyerror!void {
    //var hInstance = c.GetModuleHandleW(null);
    std.log.info("This terminal is needed :(",.{});
    hook = c.SetWindowsHookExW(c.WH_KEYBOARD_LL, Keyboard_Proc, null, 0);
    const text = 
        \\To kill all fullscreen windows quickly tap P key tree times.
        \\To exit this programm press ok.
    ;
    _ = c.MessageBoxA(0, text, "warning", 0);
}
