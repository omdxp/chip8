const config = @import("config.zig");
const CHIP8Mem = @import("chip8mem.zig").CHIP8Mem;
const CHIP8Regs = @import("chip8regs.zig").CHIP8Regs;
const CHIP8Stack = @import("chip8stack.zig").CHIP8Stack;
const stack_in_bounds = @import("chip8stack.zig").is_stack_in_bounds;
const CHIP8KB = @import("chip8kb.zig").CHIP8KB;
const CHIP8Scr = @import("chip8scr.zig").CHIP8Scr;

const CHIP8_DEFAULT_CHARACTER_SET: [16 * 5]u8 = [_]u8{
    0xf0, 0x90, 0x90, 0x90, 0xf0, // 0
    0x20, 0x60, 0x20, 0x20, 0x70, // 1
    0xf0, 0x10, 0xf0, 0x80, 0xf0, // 2
    0xf0, 0x10, 0xf0, 0x10, 0xf0, // 3
    0x90, 0x90, 0xf0, 0x10, 0x10, // 4
    0xf0, 0x80, 0xf0, 0x10, 0xf0, // 5
    0xf0, 0x80, 0xf0, 0x90, 0xf0, // 6
    0xf0, 0x10, 0x20, 0x40, 0x40, // 7
    0xf0, 0x90, 0xf0, 0x90, 0xf0, // 8
    0xf0, 0x90, 0xf0, 0x10, 0xf0, // 9
    0xf0, 0x90, 0xf0, 0x90, 0x90, // A
    0xf0, 0x90, 0xf0, 0x10, 0x10, // B
    0xf0, 0x80, 0x80, 0x80, 0xf0, // C
    0x70, 0x20, 0x20, 0x20, 0x70, // D
    0xf0, 0x80, 0xf0, 0x80, 0xf0, // E
    0xf0, 0x80, 0xf0, 0x80, 0x80, // F
};

pub const CHIP8 = struct {
    // Memory
    memory: CHIP8Mem,

    // Registers
    registers: CHIP8Regs,

    // Stack
    stack: CHIP8Stack,

    // Keypad
    keypad: CHIP8KB,

    // Screen
    screen: CHIP8Scr,

    const Self = @This();

    // Initialize the CHIP-8 state
    pub fn init() !Self {
        var memory = CHIP8Mem.init();
        // Load the default character set into memory
        for (0..CHIP8_DEFAULT_CHARACTER_SET.len) |i| {
            try memory.set(config.CHIP8_DEFAULT_CHARACTER_SET_ADDRESS + i, CHIP8_DEFAULT_CHARACTER_SET[i]);
        }

        return Self{
            .memory = memory,
            .registers = .init(),
            .stack = .init(),
            .keypad = .init(),
            .screen = undefined,
        };
    }

    // Push to stack
    pub fn push(self: *Self, value: u16) !void {
        if (!stack_in_bounds(self.registers.sp)) {
            return error.StackOverflow; // or some error handling
        }
        self.stack.stack[self.registers.sp] = value;
        self.registers.sp += 1;
    }

    // Pop from stack
    pub fn pop(self: *Self) !u16 {
        self.registers.sp -= 1;
        if (!stack_in_bounds(self.registers.sp)) {
            return error.StackUnderflow; // or some error handling
        }
        return self.stack.stack[self.registers.sp];
    }

    // Reset the CHIP-8 state
    pub fn reset(self: *Self) void {
        self.memory.clear();
        self.registers = CHIP8Regs{};
        self.stack = CHIP8Stack{};
    }

    // Execute an opcode
    pub fn execute(self: *Self, opcode: u16) !void {
        // Decode and execute the opcode
        // This is a simplified example; actual implementation will vary
        switch (opcode & 0xF000) {
            0x0000 => {},
            0x1000 => |addr| {
                self.registers.pc = addr & 0x0FFF; // Jump to address
            },
            0x2000 => |addr| {
                try self.push(self.registers.pc); // Call subroutine
                self.registers.pc = addr & 0x0FFF;
            },
            // Add more opcodes as needed...
            else => return error.InvalidOpcode, // Invalid opcode
        }
    }

    // Load a program into memory
    pub fn load_program(self: *Self, program: []const u8) !void {
        if (program.len > self.memory.memory.len - config.CHIP8_PROGRAM_START_ADDRESS) {
            return error.ProgramTooLarge; // or some error handling
        }
        for (0..program.len) |i| {
            try self.memory.set(config.CHIP8_PROGRAM_START_ADDRESS + i, program[i]);
        }
        self.registers.pc = config.CHIP8_PROGRAM_START_ADDRESS; // Set the program counter to the start of the program
    }
};
