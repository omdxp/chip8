const config = @import("config.zig");

inline fn is_key_in_bounds(key: u8) bool {
    return key < config.CHIP8_NUM_KEYS;
}

pub const CHIP8KB = struct {
    // Keypad state
    keys: [config.CHIP8_NUM_KEYS]bool = undefined,

    const Self = @This();

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
};
