// Memory size in bytes
pub const CHIP8_MEMORY_SIZE: usize = 4096;

// Number of registers
pub const CHIP8_NUM_REGISTERS: usize = 16;

// VF register index
pub const CHIP8_VF_INDEX: usize = 0x0F;

// Program counter initial value
pub const CHIP8_PC_INITIAL: u16 = 0x200;

// Stack size
pub const CHIP8_STACK_SIZE: usize = 16;

// Display dimensions
pub const CHIP8_WIDTH: usize = 64;
pub const CHIP8_HEIGHT: usize = 32;
pub const CHIP8_WINDOW_MULTIPLIER: usize = 10;

// Initial value for timers
pub const CHIP8_TIMER_INITIAL: u8 = 60;

// Total number of keys
pub const CHIP8_NUM_KEYS: usize = 16;

// Default character set load address
pub const CHIP8_DEFAULT_CHARACTER_SET_ADDRESS: u16 = 0x00;

// Program start address
pub const CHIP8_PROGRAM_START_ADDRESS: u16 = 0x200;

// Emulator title
pub const EMULATOR_WINDOW_TITLE: [*c]const u8 = "Chip8 Emulator";
