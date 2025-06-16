# CHIP-8 Emulator in Zig

A simple CHIP-8 emulator written in Zig, using SDL2 for graphics and keyboard input. This project is intended for learning, experimentation, and playing classic CHIP-8 games.

## Features
- Interprets and runs CHIP-8 ROMs
- SDL2-based graphics and input
- Sound support (beep)
- Command-line interface for loading games
- Cross-platform (tested on macOS)

## Requirements
- [Zig](https://ziglang.org/) 0.14.0 or newer
- [SDL2](https://www.libsdl.org/) development libraries (dynamically linked)
  - On macOS, you can install SDL2 with Homebrew: `brew install sdl2`
  - **Note:** SDL2 must be available as a dynamic library at runtime (e.g., `libSDL2.dylib` on macOS)

## Building

1. Install Zig and SDL2 (on macOS, use Homebrew):
   ```fish
   brew install zig sdl2
   ```
2. Clone this repository and enter the directory.
3. Build the emulator:
   ```fish
   zig build
   ```

## Running

To run a CHIP-8 game:
```fish
zig build run -- -p games/PONG
```
Replace `games/PONG` with the path to any CHIP-8 ROM in the `games/` directory.

**Note:** SDL2 is dynamically linked. You must have the SDL2 dynamic library (`libSDL2.dylib` on macOS) available in your system library path. If you get a library not found error, ensure SDL2 is installed and your library path is set correctly.

## Controls
- CHIP-8 keypad is mapped to your keyboard (see `main.zig` for mapping)
- ESC or window close to exit

## Project Structure
- `src/` — Zig source files
- `games/` — Example CHIP-8 ROMs
- `build.zig` — Zig build script

## Acknowledgments
- [Zig language](https://ziglang.org/)
- [SDL2](https://www.libsdl.org/)
- [CHIP-8 documentation and community](http://devernay.free.fr/hacks/chip8/C8TECH10.HTM)

## License
MIT License. See source files for details.
