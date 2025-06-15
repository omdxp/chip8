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

    // Initialize the CHIP-8 registers
    pub fn init() Self {
        return Self{
            .v = [_]u8{0} ** config.CHIP8_NUM_REGISTERS,
            .i = 0,
            .delay_timer = config.CHIP8_TIMER_INITIAL,
            .sound_timer = config.CHIP8_TIMER_INITIAL,
            .pc = config.CHIP8_PC_INITIAL,
            .sp = 0,
        };
    }
};
