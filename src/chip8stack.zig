const config = @import("config.zig");

pub inline fn is_stack_in_bounds(index: usize) bool {
    return index < config.CHIP8_STACK_SIZE;
}

pub const CHIP8Stack = struct {
    // Stack
    stack: [config.CHIP8_STACK_SIZE]u16 = undefined,

    const Self = @This();

    // Initialize the CHIP-8 stack
    pub fn init() Self {
        return Self{
            .stack = [_]u16{0} ** config.CHIP8_STACK_SIZE,
        };
    }
};
