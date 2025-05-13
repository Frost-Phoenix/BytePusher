const rl = @import("raylib");
const std = @import("std");

const bp = @import("bytepusher.zig");
const SCREEN_SIZE = bp.SCREEN_SIZE;

// ***** //

const FPS = 60;
const SCALE = 2;
const WINDOW_SIZE = SCREEN_SIZE * SCALE;

// ***** public ***** //

pub fn main() !void {
    rl.initWindow(WINDOW_SIZE, WINDOW_SIZE, "BytePusher");
    defer rl.closeWindow();

    rl.setTargetFPS(FPS);

    try bp.init();
    defer bp.deinit();

    try bp.loadRom("roms/Sprites.BytePusher");

    while (!rl.windowShouldClose()) {
        bp.updateFrame();
        render();
    }
}

fn render() void {
    rl.beginDrawing();
    defer rl.endDrawing();

    const src: rl.Rectangle = .init(0, 0, SCREEN_SIZE, -SCREEN_SIZE);
    const dest: rl.Rectangle = .init(0, 0, WINDOW_SIZE, WINDOW_SIZE);

    rl.drawTexturePro(bp.frame_buffer.texture, src, dest, .init(0, 0), 0, .white);
}
