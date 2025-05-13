const rl = @import("raylib");
const std = @import("std");

const readInt = std.mem.readInt;
const writeInt = std.mem.writeInt;

// ***** //

pub const SCREEN_SIZE = 256;

const CYCLES_PER_FRAME = 65536;

const MEMORY_SIZE = 0x1000008;
const COLOR_MAP_SIZE = 256;
const COLOR_STEP = 0x33;

var memory: [MEMORY_SIZE]u8 = undefined;

const color_map: [COLOR_MAP_SIZE]rl.Color = initColorMap();
const keys: [16]rl.KeyboardKey = .{
    .x,    .one, .two, .three,
    .q,    .w,   .e,   .a,
    .s,    .d,   .z,   .c,
    .four, .r,   .f,   .v,
};

pub var frame_buffer: rl.RenderTexture2D = undefined;

// ***** private functions ***** //

fn initColorMap() [COLOR_MAP_SIZE]rl.Color {
    var colors: [COLOR_MAP_SIZE]rl.Color = undefined;

    for (0..6) |r| for (0..6) |g| for (0..6) |b| {
        colors[r * 36 + g * 6 + b] = .init(
            r * COLOR_STEP,
            g * COLOR_STEP,
            b * COLOR_STEP,
            0xff,
        );
    };

    @memset(colors[216..], .black);

    return colors;
}

fn updateKeys() void {
    var buff: u16 = 0x0000;

    for (keys, 0..) |key, i| {
        if (rl.isKeyDown(key)) {
            buff |= @as(u16, 1) << @intCast(i);
        }
    }

    writeInt(u16, memory[0..2], buff, .big);
}

fn runFrameCycles() void {
    var pc: u24 = readInt(u24, @ptrCast(memory[2..]), .big);

    for (0..CYCLES_PER_FRAME) |_| {
        const a = readInt(u24, @ptrCast(memory[pc..]), .big);
        const b = readInt(u24, @ptrCast(memory[pc + 3 ..]), .big);

        memory[b] = memory[a];

        pc = readInt(u24, @ptrCast(memory[pc + 6 ..]), .big);
    }
}

fn renderFrame() void {
    frame_buffer.begin();
    defer frame_buffer.end();

    rl.clearBackground(.magenta);

    const pixels_mem_offset: u24 = memory[5];

    for (0..SCREEN_SIZE) |y| for (0..SCREEN_SIZE) |x| {
        const pixel_addr = pixels_mem_offset << 16 | y << 8 | x;
        const color_id = memory[pixel_addr];
        const color = color_map[color_id];

        rl.drawPixel(
            @intCast(x),
            @intCast(y),
            color,
        );
    };
}

// ***** public functions ***** //

pub fn init() !void {
    frame_buffer = try .init(SCREEN_SIZE, SCREEN_SIZE);
}

pub fn deinit() void {
    frame_buffer.unload();
}

pub fn loadRom(path: []const u8) !void {
    const fs = std.fs;

    const rom_path = fs.path.dirname(path) orelse "./";
    const rom_name = fs.path.basename(path);

    var dir = try fs.cwd().openDir(rom_path, .{});
    defer dir.close();

    const rom_stats = try dir.statFile(rom_name);
    const rom_size = rom_stats.size;

    if (rom_size > MEMORY_SIZE) {
        @panic("rom to big");
    }

    const rom = try dir.openFile(rom_name, .{});
    defer rom.close();

    @memset(&memory, 0);
    const byte_read = try rom.readAll(&memory);

    if (byte_read != rom_size) {
        @panic("didn't read whole file");
    }
}

pub fn updateFrame() void {
    updateKeys();
    runFrameCycles();
    renderFrame();
}
