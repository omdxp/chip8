const config = @import("config.zig");
const CHIP8Mem = @import("chip8mem.zig").CHIP8Mem;
const CHIP8Regs = @import("chip8regs.zig").CHIP8Regs;

pub const CHIP8 = struct {
    // Memory
    memory: CHIP8Mem,

    // Registers
    registers: CHIP8Regs,
};
