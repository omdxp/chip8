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
        for (&self.pixels) |*row| {
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

    // Draw sprite at (x, y) with width and height
    pub fn draw_sprite(self: *Self, x: usize, y: usize, sprite: [*c]const u8, nbytes: usize) !bool {
        var collision = false;
        for (0..nbytes) |i| {
            const byte = sprite[i];
            for (0..8) |bit| {
                const shift_amt: u3 = @intCast(7 - bit);
                if (((byte >> shift_amt) & 1) != 0) {
                    const pixel_x = (x + bit) % config.CHIP8_WIDTH;
                    const pixel_y = (y + i) % config.CHIP8_HEIGHT;

                    // Check for collision
                    if (self.is_pixel_set(pixel_x, pixel_y)) {
                        collision = true;
                    }

                    // Set the pixel
                    try self.set_pixel(pixel_x, pixel_y, !self.is_pixel_set(pixel_x, pixel_y));
                }
            }
        }
        return collision;
    }
};
