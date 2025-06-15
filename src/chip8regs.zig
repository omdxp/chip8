const config = @import("config.zig");

pub const CHIP8Regs = struct {
    // Registers
    v: [config.CHIP8_NUM_REGISTERS]u8 = undefined,

    // Index register
    i: u16 = 0,

    // Delay timer
    delay_timer: u8 = config.CHIP8_TIMER_INITIAL,

    // Sound timer
    sound_timer: u8 = config.CHIP8_TIMER_INITIAL,

    // Program counter
    pc: u16 = config.CHIP8_PC_INITIAL,

    // Stack pointer
    sp: u8 = 0,

    const Self = @This();
};
