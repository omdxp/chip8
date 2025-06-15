const config = @import("config.zig");
const CHIP8Mem = @import("chip8mem.zig").CHIP8Mem;

pub const CHIP8 = struct {
    // Memory
    memory: CHIP8Mem,
};
