const rl = @import("raylib");

const screen_width = 800;
const screen_height = 450;

pub fn main() !void {
    rl.initWindow(screen_width, screen_height, "template");
    defer rl.closeWindow();

    rl.setTargetFPS(60);

    while (!rl.windowShouldClose()) {
        // Update

        // Draw
        rl.beginDrawing();
        defer rl.endDrawing();

        rl.clearBackground(.gray);
    }
}
