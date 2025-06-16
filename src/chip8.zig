const std = @import("std");
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
        if (!stack_in_bounds(self.registers.sp)) {
            return error.StackUnderflow; // or some error handling
        }
        const res = self.stack.stack[self.registers.sp];
        self.registers.sp -= 1;
        return res;
    }

    // Reset the CHIP-8 state
    pub fn reset(self: *Self) void {
        self.memory.clear();
        self.registers = CHIP8Regs{};
        self.stack = CHIP8Stack{};
    }

    // Execute an opcode
    pub fn execute(self: *Self, opcode: u16) !void {
        std.debug.print("last opcode: {x}\n", .{opcode});
        switch (opcode) {
            // Clear the display
            0x00E0 => self.screen.clear(),
            // Return from subroutine
            0x00EE => {
                self.registers.pc = self.pop() catch |err| {
                    return err; // Handle stack underflow
                };
            },
            else => {
                return self.execute_extended(opcode) catch |err| {
                    return err; // Handle unhandled opcode
                };
            },
        }
    }

    // Execute an extended opcode
    pub fn execute_extended(self: *Self, opcode: u16) !void {
        const nnn = opcode & 0x0FFF; // Address
        const x = (opcode >> 8) & 0x000F; // Register index
        const y = (opcode >> 4) & 0x000F; // Second register index
        const kk: u8 = @intCast(opcode & 0x00FF); // Immediate value
        const nibble = opcode & 0x000F; // Nibble (last 4 bits)

        switch (opcode & 0xF000) {
            // 0x1NNN: Jump to address NNN
            0x1000 => self.registers.pc = nnn,
            // 0x2NNN: Call subroutine at NNN
            0x2000 => {
                try self.push(self.registers.pc);
                self.registers.pc = nnn;
            },
            // 0x3XKK: Skip next instruction if Vx == KK
            0x3000 => {
                if (self.registers.v[x] == kk) {
                    self.registers.pc += 2; // Skip next instruction
                }
            },
            // 0x4XKK: Skip next instruction if Vx != KK
            0x4000 => {
                if (self.registers.v[x] != kk) {
                    self.registers.pc += 2; // Skip next instruction
                }
            },
            // 0x5XY0: Skip next instruction if Vx == Vy
            0x5000 => {
                if (self.registers.v[x] == self.registers.v[y]) {
                    self.registers.pc += 2; // Skip next instruction
                }
            },
            // 0x6XKK: Set Vx = KK
            0x6000 => self.registers.v[x] = kk,
            // 0x7XKK: Set Vx += KK
            0x7000 => {
                self.registers.v[x] = @as(u8, self.registers.v[x] + kk);
            },
            // 0x8000 cases
            0x8000 => self.execute_extended_8000(opcode) catch |err| {
                return err; // Handle unhandled opcode
            },
            // 0x9XY0: Skip next instruction if Vx != Vy
            0x9000 => {
                if (self.registers.v[x] != self.registers.v[y]) {
                    self.registers.pc += 2; // Skip next instruction
                }
            },
            // 0xANNN: Set I = NNN
            0xA000 => self.registers.i = nnn,
            // 0xBNNN: Jump to address NNN + V0
            0xB000 => self.registers.pc = nnn + @as(u16, self.registers.v[0]),
            // 0xCXKK: Set Vx = random byte AND KK
            0xC000 => {
                var random = std.Random.DefaultPrng.init(@intCast(std.time.milliTimestamp()));
                const random_byte = random.random().intRangeLessThan(u8, 0, 255);
                self.registers.v[x] = random_byte & kk; // Set Vx to random byte AND KK
            },
            // 0xDXYN: Draw sprite at (Vx, Vy) with height N
            0xD000 => {
                const sprite = self.memory.get(self.registers.i) catch |err| {
                    return err; // Handle memory access error
                };
                const collision = self.screen.draw_sprite(
                    @intCast(self.registers.v[x]),
                    @intCast(self.registers.v[y]),
                    &sprite,
                    nibble,
                ) catch |err| {
                    return err; // Handle screen draw error
                };
                // Set VF to 1 if there was a collision, otherwise set it to 0
                self.registers.v[config.CHIP8_VF_INDEX] = if (collision) 1 else 0;
            },
            // 0xE000: Skip next instruction if key Vx is pressed
            0xE000 => switch (kk) {
                // 0xEX9E: Skip next instruction if key Vx is pressed
                0x009E => {
                    if (try self.keypad.is_key_pressed(self.registers.v[x])) {
                        self.registers.pc += 2; // Skip next instruction
                    }
                },
                // 0xEXA1: Skip next instruction if key Vx is not pressed
                0x00A1 => {
                    if (!try self.keypad.is_key_pressed(self.registers.v[x])) {
                        self.registers.pc += 2; // Skip next instruction
                    }
                },
                else => return error.UnhandledOpcode, // Handle unhandled opcode
            },
            // 0xF000 cases
            0xF000 => self.execute_extended_f000(opcode) catch |err| {
                return err; // Handle unhandled opcode
            },
            // Other opcodes can be implemented similarly...
            else => {}, // Handle unhandled opcode
        }
    }

    // Execute 0xF000 opcodes
    pub fn execute_extended_f000(self: *Self, opcode: u16) !void {
        const x = (opcode >> 8) & 0x000F; // Register index

        switch (opcode & 0x00FF) {
            // 0xFX07: Set Vx = delay timer
            0x0007 => self.registers.v[x] = self.registers.delay_timer,
            // 0xFX0A: Wait for key press, store in Vx
            0x000A => {
                const key = try self.keypad.wait_for_key_press();
                self.registers.v[x] = key;
            },
            // 0xFX15: Set delay timer = Vx
            0x0015 => self.registers.delay_timer = self.registers.v[x],
            // 0xFX18: Set sound timer = Vx
            0x0018 => self.registers.sound_timer = self.registers.v[x],
            // 0xFX1E: Set I += Vx
            0x001E => {
                self.registers.i += @as(u16, self.registers.v[x]);
                if (self.registers.i > 0xFFF) {
                    return error.OutOfBounds; // Handle out of bounds access
                }
            },
            // 0xFX29: Set I to the location of the sprite for digit Vx
            0x0029 => {
                const digit = self.registers.v[x];
                if (digit > 15) {
                    return error.InvalidDigit; // Handle invalid digit
                }
                self.registers.i = config.CHIP8_DEFAULT_CHARACTER_SET_ADDRESS + (digit * 5);
            },
            // 0xFX33: Store BCD representation of Vx in memory at I, I+1, I+2
            0x0033 => {
                const value = self.registers.v[x];
                try self.memory.set(self.registers.i, @as(u8, value / 100));
                try self.memory.set(self.registers.i + 1, @as(u8, (value / 10) % 10));
                try self.memory.set(self.registers.i + 2, @as(u8, value % 10));
            },
            // 0xFX55: Store registers V0 to Vx in memory starting at I
            0x0055 => {
                for (0..x) |i| {
                    try self.memory.set(self.registers.i + i, self.registers.v[i]);
                }
                self.registers.i += @as(u16, x + 1); // Increment I by the number of registers stored
            },
            // 0xFX65: Read registers V0 to Vx from memory starting at I
            0x0065 => {
                for (0..x) |i| {
                    self.registers.v[i] = try self.memory.get(self.registers.i + i);
                }
                self.registers.i += @as(u16, x + 1); // Increment I by the number of registers read
            },
            else => {}, // Handle unhandled opcode
        }
    }

    // Execute 0x8000 opcodes
    pub fn execute_extended_8000(self: *Self, opcode: u16) !void {
        const x = (opcode >> 8) & 0x000F; // Register index
        const y = (opcode >> 4) & 0x000F; // Second register index

        switch (opcode & 0x000F) {
            // 0x8XY0: Set Vx = Vy
            0x0000 => self.registers.v[x] = self.registers.v[y],
            // 0x8XY1: Set Vx = Vx OR Vy
            0x0001 => self.registers.v[x] |= self.registers.v[y],
            // 0x8XY2: Set Vx = Vx AND Vy
            0x0002 => self.registers.v[x] &= self.registers.v[y],
            // 0x8XY3: Set Vx = Vx XOR Vy
            0x0003 => self.registers.v[x] ^= self.registers.v[y],
            // 0x8XY4: Set Vx += Vy, set VF = carry
            0x0004 => {
                const sum = @as(u16, self.registers.v[x]) + @as(u16, self.registers.v[y]);
                self.registers.v[config.CHIP8_VF_INDEX] = if (sum > 255) 1 else 0;
                self.registers.v[x] = @intCast(sum);
            },
            // 0x8XY5: Set Vx -= Vy, set VF = NOT borrow
            0x0005 => {
                self.registers.v[config.CHIP8_VF_INDEX] = if (self.registers.v[x] > self.registers.v[y]) 1 else 0;
                self.registers.v[x] -= self.registers.v[y];
            },
            // 0x8XY6: Set Vx = Vx SHR 1, set VF = LSB of Vx before shift
            0x0006 => {
                self.registers.v[config.CHIP8_VF_INDEX] = self.registers.v[x] & 0x01; // Store LSB in VF
                self.registers.v[x] >>= 1; // Shift right
            },
            // 0x8XY7: Set Vx = Vy - Vx, set VF = NOT borrow
            0x0007 => {
                self.registers.v[config.CHIP8_VF_INDEX] = if (self.registers.v[y] > self.registers.v[x]) 1 else 0;
                self.registers.v[x] = @as(u8, self.registers.v[y] - self.registers.v[x]);
            },
            // 0x8XYE: Set Vx = Vx SHL 1, set VF = MSB of Vx before shift
            0x000E => {
                self.registers.v[config.CHIP8_VF_INDEX] = (self.registers.v[x] >> 7) & 0x01; // Store MSB in VF
                self.registers.v[x] <<= 1; // Shift left
            },
            // Other cases can be implemented similarly...
            else => {}, // Handle unhandled opcode
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
