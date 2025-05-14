const rl = @import("raylib");
const std = @import("std");

const BUILD_MODE = @import("builtin").mode;

const bp = @import("bytepusher.zig");
const SCREEN_SIZE = bp.SCREEN_SIZE;

// ***** //

const FPS = 60;
const SCALE = 2;
const WINDOW_SIZE = SCREEN_SIZE * SCALE;

const ArgsError = error{
    InvalidArgumentNumber,
};

// ***** public ***** //

pub fn main() !void {
    var gpa: std.heap.GeneralPurposeAllocator(.{}) = .init;
    defer _ = gpa.deinit();
    const allocator = gpa.allocator();

    const args = try std.process.argsAlloc(allocator);
    defer std.process.argsFree(allocator, args);

    if (args.len != 2) {
        try help();
        return ArgsError.InvalidArgumentNumber;
    }

    const rom_path = args[1];
    try bp.loadRom(rom_path);

    if (BUILD_MODE == .Debug) {
        rl.setTraceLogLevel(.debug);
    } else rl.setTraceLogLevel(.warning);

    rl.initWindow(WINDOW_SIZE, WINDOW_SIZE, "BytePusher");
    defer rl.closeWindow();

    try bp.init();
    defer bp.deinit();

    rl.setTargetFPS(FPS);

    while (!rl.windowShouldClose()) {
        bp.updateFrame();
        render();
    }
}

fn help() !void {
    const stderr = std.io.getStdErr();
    const writer = stderr.writer();

    try writer.writeAll("\x1b[1mUsage:\x1b[0m bytepusher <rom-path>\n");
}

fn render() void {
    rl.beginDrawing();
    defer rl.endDrawing();

    const src: rl.Rectangle = .init(0, 0, SCREEN_SIZE, -SCREEN_SIZE);
    const dest: rl.Rectangle = .init(0, 0, WINDOW_SIZE, WINDOW_SIZE);

    rl.drawTexturePro(bp.frame_buffer.texture, src, dest, .init(0, 0), 0, .white);
}
