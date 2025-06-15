const config = @import("config.zig");

inline fn is_memory_in_bounds(index: usize) bool {
    return index >= 0 and index < config.CHIP8_MEMORY_SIZE;
}

pub const CHIP8Mem = struct {
    // Memory
    memory: [config.CHIP8_MEMORY_SIZE]u8 = undefined,

    const Self = @This();

    // Memory set
    pub fn set(self: *Self, index: usize, value: u8) !void {
        if (!is_memory_in_bounds(index)) {
            // Handle out of bounds access
            return error.OutOfBounds; // or some error handling
        }
        self.memory[index] = value;
    }

    // Memory get
    pub fn get(self: *const Self, index: usize) !u8 {
        if (!is_memory_in_bounds(index)) {
            // Handle out of bounds access
            return error.OutOfBounds; // or some error handling
        }
        return self.memory[index];
    }

    // Memory clear
    pub fn clear(self: *Self) void {
        for (self.memory) |*byte| {
            byte.* = 0;
        }
    }
};
