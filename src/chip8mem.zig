const config = @import("config.zig");

inline fn is_memory_in_bounds(index: usize) bool {
    return index < config.CHIP8_MEMORY_SIZE;
}

pub const CHIP8Mem = struct {
    // Memory
    memory: [config.CHIP8_MEMORY_SIZE]u8 = undefined,

    const Self = @This();

    // Initialize the CHIP-8 memory
    pub fn init() Self {
        return Self{
            .memory = [_]u8{0} ** config.CHIP8_MEMORY_SIZE,
        };
    }

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

    // Memory get short
    pub fn get_short(self: *const Self, index: usize) !u16 {
        if (!is_memory_in_bounds(index) or !is_memory_in_bounds(index + 1)) {
            // Handle out of bounds access
            return error.OutOfBounds; // or some error handling
        }
        const high = try self.get(index);
        const low = try self.get(index + 1);
        return @as(u16, high) << 8 | @as(u16, low);
    }

    // Memory clear
    pub fn clear(self: *Self) void {
        for (&self.memory) |*byte| {
            byte.* = 0;
        }
    }
};
