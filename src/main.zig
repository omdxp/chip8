const std = @import("std");
const SDL = @import("sdl2");

pub fn main() !void {
    _ = SDL.SDL_Init(SDL.SDL_INIT_EVERYTHING);
    const window = SDL.SDL_CreateWindow(
        "Chip8 Emulator",
        SDL.SDL_WINDOWPOS_UNDEFINED,
        SDL.SDL_WINDOWPOS_UNDEFINED,
        640,
        480,
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
