const config = @import("config.zig");

pub const CHIP8 = struct {
    // Memory
    memory: [config.CHIP8_MEMORY_SIZE]u8 = undefined,

    // Registers
    registers: [config.CHIP8_NUM_REGISTERS]u8 = undefined,

    // Program counter
    pc: u16 = config.CHIP8_PC_INITIAL,

    // Stack
    stack: [config.CHIP8_STACK_SIZE]u16 = undefined,
    sp: usize = 0, // Stack pointer

    // Display buffer
    display: [config.CHIP8_WIDTH * config.CHIP8_HEIGHT]u8 = undefined,

    // Timers
    delay_timer: u8 = config.CHIP8_TIMER_INITIAL,
    sound_timer: u8 = config.CHIP8_TIMER_INITIAL,
};
