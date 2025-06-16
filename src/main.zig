const std = @import("std");
const SDL = @import("sdl2");
const config = @import("config.zig");
const CHIP8 = @import("chip8.zig").CHIP8;
const CHIP8KB = @import("chip8kb.zig").CHIP8KB;
const beep = @import("beep.zig").beep;
const clap = @import("clap");

pub const keypad_map: [config.CHIP8_NUM_KEYS]u8 = [_]u8{
    SDL.SDLK_0, SDL.SDLK_1, SDL.SDLK_2, SDL.SDLK_3,
    SDL.SDLK_4, SDL.SDLK_5, SDL.SDLK_6, SDL.SDLK_7,
    SDL.SDLK_8, SDL.SDLK_9, SDL.SDLK_a, SDL.SDLK_b,
    SDL.SDLK_c, SDL.SDLK_d, SDL.SDLK_e, SDL.SDLK_f,
};

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();

    const params = comptime clap.parseParamsComptime(
        \\-h, --help  Display this help and exit.
        \\-p, --program <string>  Path to the CHIP-8 program file.
        \\--version  Display version information and exit.
    );
    var diag = clap.Diagnostic{};
    var res = clap.parse(clap.Help, &params, clap.parsers.default, .{
        .diagnostic = &diag,
        .allocator = gpa.allocator(),
    }) catch |err| {
        diag.report(std.io.getStdErr().writer(), err) catch {};
        return err;
    };
    defer res.deinit();

    var program_data: []const u8 = undefined;
    if (res.args.program) |program_path| {
        const program_file = std.fs.cwd().openFile(program_path, .{ .mode = .read_only }) catch |err| {
            std.debug.print("Error opening program file: {}\n", .{err});
            return err;
        };
        defer program_file.close();

        program_data = program_file.readToEndAlloc(gpa.allocator(), 4096) catch |err| {
            std.debug.print("Error reading program file: {}\n", .{err});
            return err;
        };
    } else {
        std.debug.print("No program specified. Use -p or --program to specify a CHIP-8 program file.\n", .{});
        return error.NoProgramSpecified;
    }
    defer gpa.allocator().free(program_data);

    for (program_data) |byte| {
        if (byte > 0xFF) {
            std.debug.print("Invalid byte in program data: {}\n", .{byte});
            return error.InvalidProgramData;
        }
    }

    var chip8: CHIP8 = try .init();
    // chip8.registers.delay_timer = 0;
    chip8.registers.sound_timer = 0;
    chip8.load_program(program_data) catch |err| {
        std.debug.print("Error loading program: {}\n", .{err});
        return err;
    };
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

        if (chip8.registers.delay_timer > 0) {
            std.time.sleep(10);
            chip8.registers.delay_timer -= 1;
        }

        if (chip8.registers.sound_timer > 0) {
            _ = beep(15000, 10 * @as(c_int, chip8.registers.sound_timer)); // Beep at 15kHz for sound timer
            chip8.registers.sound_timer = 0;
        }

        const opcode = chip8.memory.get_short(chip8.registers.pc) catch |err| {
            std.debug.print("Error reading opcode: {}\n", .{err});
            return err;
        };
        chip8.registers.pc += 2;
        chip8.execute(opcode) catch |err| {
            std.debug.print("Error executing opcode: {}\n", .{err});
            return err;
        };
    }
}
