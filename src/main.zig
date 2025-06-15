const std = @import("std");
const SDL = @import("sdl2");
const config = @import("config.zig");
const CHIP8 = @import("chip8.zig").CHIP8;

pub fn main() !void {
    var chip8: CHIP8 = undefined;
    chip8.registers.sp = 0;
    chip8.push(0xff) catch |err| {
        std.debug.print("Error pushing to stack: {}\n", .{err});
    };
    const popped_value = chip8.pop() catch |err| {
        std.debug.print("Error popping from stack: {}\n", .{err});
        return err;
    };
    std.debug.print("Popped value: 0x{x}\n", .{popped_value});
    chip8.reset();
    std.debug.print("CHIP-8 state reset.\n", .{});
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
            if (event.type == SDL.SDL_QUIT) {
                return;
            }
        }
        _ = SDL.SDL_SetRenderDrawColor(renderer, 0, 0, 0, 0);
        _ = SDL.SDL_RenderClear(renderer);
        _ = SDL.SDL_SetRenderDrawColor(renderer, 255, 255, 255, 255);
        var rect = SDL.SDL_Rect{
            .x = 0,
            .y = 0,
            .w = 40,
            .h = 40,
        };
        _ = SDL.SDL_RenderFillRect(renderer, &rect);
        SDL.SDL_RenderPresent(renderer);
    }
}
