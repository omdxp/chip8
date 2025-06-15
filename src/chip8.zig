const config = @import("config.zig");
const CHIP8Mem = @import("chip8mem.zig").CHIP8Mem;
const CHIP8Regs = @import("chip8regs.zig").CHIP8Regs;
const CHIP8Stack = @import("chip8stack.zig").CHIP8Stack;
const stack_in_bounds = @import("chip8stack.zig").is_stack_in_bounds;
const CHIP8KB = @import("chip8kb.zig").CHIP8KB;

pub const CHIP8 = struct {
    // Memory
    memory: CHIP8Mem,

    // Registers
    registers: CHIP8Regs,

    // Stack
    stack: CHIP8Stack,

    // Keypad
    keypad: CHIP8KB,

    const Self = @This();

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
};
