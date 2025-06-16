const config = @import("config.zig");
const SDL = @import("sdl2");
const keypad_map = @import("main.zig").keypad_map;

inline fn is_key_in_bounds(key: u8) bool {
    return key < config.CHIP8_NUM_KEYS;
}

pub const CHIP8KB = struct {
    // Keypad state
    keys: [config.CHIP8_NUM_KEYS]bool = undefined,

    const Self = @This();

    // Initialize the CHIP-8 keypad
    pub fn init() Self {
        return Self{
            .keys = [_]bool{false} ** config.CHIP8_NUM_KEYS,
        };
    }

    // Set a key state
    pub fn set_key(self: *Self, key: u8, pressed: bool) !void {
        if (!is_key_in_bounds(key)) {
            return error.InvalidKey; // or some error handling
        }
        self.keys[key] = pressed;
    }

    // Get a key state
    pub fn get_key(self: *const Self, key: u8) !bool {
        if (!is_key_in_bounds(key)) {
            return error.InvalidKey; // or some error handling
        }
        return self.keys[key];
    }

    // Key down
    pub fn key_down(self: *Self, key: u8) !void {
        return self.set_key(key, true);
    }

    // Key up
    pub fn key_up(self: *Self, key: u8) !void {
        return self.set_key(key, false);
    }

    // Check if a key is pressed
    pub fn is_key_pressed(self: *const Self, key: u8) !bool {
        if (!is_key_in_bounds(key)) {
            return error.InvalidKey; // or some error handling
        }
        return self.keys[key];
    }

    // Keyboard map
    pub fn get_key_map(map: *const [config.CHIP8_NUM_KEYS]u8, key: u8) !u8 {
        for (0..16) |i| {
            if (map[i] == key) {
                return @intCast(i); // Return the index as the key mapping
            }
        }
        return error.KeyNotMapped; // or some error handling
    }

    // Reset the keypad state
    pub fn reset(self: *Self) void {
        for (&self.keys) |*key| {
            key.* = false;
        }
    }

    // Wait for a key press
    pub fn wait_for_key_press(self: *Self) !u8 {
        var event: SDL.SDL_Event = undefined;
        while (SDL.SDL_WaitEvent(&event) != 0) {
            if (event.type == SDL.SDL_KEYDOWN) {
                const key = event.key.keysym.sym;
                const vkey = try Self.get_key_map(&keypad_map, @intCast(key));
                try self.key_down(vkey);
                return vkey;
            } else if (event.type == SDL.SDL_QUIT) {
                return error.QuitRequested; // Handle quit event
            }
        }
        return error.NoKeyPressed; // or some error handling
    }
};
