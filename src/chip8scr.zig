const config = @import("config.zig");

pub inline fn is_screen_in_bounds(x: usize, y: usize) bool {
    return x < config.CHIP8_WIDTH and y < config.CHIP8_HEIGHT;
}

pub const CHIP8Scr = struct {
    // Screen pixels
    pixels: [config.CHIP8_HEIGHT][config.CHIP8_WIDTH]bool,

    const Self = @This();

    // Clear the screen
    pub fn clear(self: *Self) void {
        for (self.pixels) |*row| {
            for (row) |*pixel| {
                pixel.* = false;
            }
        }
    }

    // Set a pixel at (x, y)
    pub fn set_pixel(self: *Self, x: usize, y: usize, value: bool) !void {
        if (!is_screen_in_bounds(x, y)) {
            // Handle out of bounds access
            return error.OutOfBounds; // or some error handling
        }
        self.pixels[y][x] = value;
    }

    // Is pixel at (x, y) set?
    pub fn is_pixel_set(self: *const Self, x: usize, y: usize) bool {
        if (!is_screen_in_bounds(x, y)) {
            // Handle out of bounds access
            return false; // or some error handling
        }
        return self.pixels[y][x];
    }
};
