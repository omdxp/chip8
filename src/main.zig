const std = @import("std");
const SDL = @import("sdl2");
const config = @import("config.zig");
const CHIP8 = @import("chip8.zig").CHIP8;
const CHIP8KB = @import("chip8kb.zig").CHIP8KB;

const keypad_map: [config.CHIP8_NUM_KEYS]u8 = [_]u8{
    SDL.SDLK_0, SDL.SDLK_1, SDL.SDLK_2, SDL.SDLK_3,
    SDL.SDLK_4, SDL.SDLK_5, SDL.SDLK_6, SDL.SDLK_7,
    SDL.SDLK_8, SDL.SDLK_9, SDL.SDLK_a, SDL.SDLK_b,
    SDL.SDLK_c, SDL.SDLK_d, SDL.SDLK_e, SDL.SDLK_f,
};

pub fn main() !void {
    var chip8: CHIP8 = try .init();
    // set some pixels to test
    try chip8.screen.set_pixel(0, 0, true);
    try chip8.screen.set_pixel(1, 1, true);
    try chip8.screen.set_pixel(2, 2, true);
    try chip8.screen.set_pixel(3, 3, true);
    _ = SDL.SDL_Init(SDL.SDL_INIT_EVERYTHING);
    const window = SDL.SDL_CreateWindow(
        config.EMULATOR_WINDOW_TITLE,
        SDL.SDL_WINDOWPOS_UNDEFINED,
        SDL.SDL_WINDOWPOS_UNDEFINED,
        config.CHIP8_WIDTH * config.CHIP8_WINDOW_MULTIPLIER,
        config.CHIP8_HEIGHT * config.CHIP8_WINDOW_MULTIPLIER,
        SDL.SDL_WINDOW_SHOWN,
    );
    defer SDL.SDL_DestroyWindow(window);

    const renderer = SDL.SDL_CreateRenderer(
        window,
        -1,
        SDL.SDL_TEXTUREACCESS_TARGET,
    );
    defer SDL.SDL_DestroyRenderer(renderer);

    while (true) {
        var event: SDL.SDL_Event = undefined;
        while (SDL.SDL_PollEvent(&event) != 0) {
            switch (event.type) {
                SDL.SDL_QUIT => {
                    return;
                },
                SDL.SDL_KEYDOWN => {
                    const key = event.key.keysym.sym;
                    const vkey = CHIP8KB.get_key_map(&keypad_map, @intCast(key)) catch |err| {
                        std.debug.print("Error getting key map: {}\n", .{err});
                        continue;
                    };
                    chip8.keypad.key_down(vkey) catch |err| {
                        std.debug.print("Error setting key down: {}\n", .{err});
                    };
                },
                SDL.SDL_KEYUP => {
                    const key = event.key.keysym.sym;
                    const vkey = CHIP8KB.get_key_map(&keypad_map, @intCast(key)) catch |err| {
                        std.debug.print("Error getting key map: {}\n", .{err});
                        continue;
                    };
                    chip8.keypad.key_up(vkey) catch |err| {
                        std.debug.print("Error setting key up: {}\n", .{err});
                    };
                },
                else => {
                    // Ignore other events
                },
            }
        }
        _ = SDL.SDL_SetRenderDrawColor(renderer, 0, 0, 0, 0);
        _ = SDL.SDL_RenderClear(renderer);
        _ = SDL.SDL_SetRenderDrawColor(renderer, 255, 255, 255, 0);
        for (0..config.CHIP8_WIDTH) |x| {
            for (0..config.CHIP8_HEIGHT) |y| {
                if (chip8.screen.is_pixel_set(x, y)) {
                    const rect = SDL.SDL_Rect{
                        .x = @intCast(x * config.CHIP8_WINDOW_MULTIPLIER),
                        .y = @intCast(y * config.CHIP8_WINDOW_MULTIPLIER),
                        .w = @intCast(config.CHIP8_WINDOW_MULTIPLIER),
                        .h = @intCast(config.CHIP8_WINDOW_MULTIPLIER),
                    };
                    _ = SDL.SDL_RenderFillRect(renderer, &rect);
                }
            }
        }
        SDL.SDL_RenderPresent(renderer);
    }
}
