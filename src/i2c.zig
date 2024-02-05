const std = @import("std");
const microzig = @import("microzig");

const rp2040 = microzig.hal;
const i2c = rp2040.i2c;
const gpio = rp2040.gpio;
const time = rp2040.time;

const i2c0 = i2c.num(0);
const led = gpio.num(25);

const ADDRESS: u8 = 0x3C;
const CONTROL_COMMAND: u8 = 0x00;
const CONTROL_DATA: u8 = 0x40;
const COMMAND_ADDRESSING_MODE = 0x20;
const COMMAND_COLUMN_ADDRESS = 0x21;
const COMMAND_PAGE_ADDRESS = 0x22;

const INIT = [_]u8{ CONTROL_COMMAND, 0xAE, CONTROL_COMMAND, 0xA8, 0x1F, CONTROL_COMMAND, 0xD3, 0x00, CONTROL_COMMAND, 0x40, CONTROL_COMMAND, 0xA0, CONTROL_COMMAND, 0xC0, CONTROL_COMMAND, 0xDA, 0x02, CONTROL_COMMAND, 0x81, 0x7F, CONTROL_COMMAND, 0xA4, CONTROL_COMMAND, 0xD5, 0x80, CONTROL_COMMAND, 0x8D, 0x14, CONTROL_COMMAND, 0xAF };

const DRAW = [_]u8{
    CONTROL_COMMAND,
    COMMAND_COLUMN_ADDRESS,
    0x00,
    0x7F,
    CONTROL_COMMAND,
    COMMAND_PAGE_ADDRESS,
    0x00,
    0x03,
};

pub fn main() !void {
    led.set_function(.sio);
    led.set_direction(.out);
    led.put(0);

    _ = i2c0.apply(.{
        .clock_config = rp2040.clock_config,
        .scl_pin = gpio.num(21),
        .sda_pin = gpio.num(20),
        .baud_rate = 100000,
    });

    time.sleep_ms(1000);

    try send(&INIT);

    time.sleep_ms(1000);
    led.put(1);
    time.sleep_ms(1000);
    led.put(0);

    const set_addressing_mode = [3]u8{ CONTROL_COMMAND, COMMAND_ADDRESSING_MODE, 0b00 };
    try send(&set_addressing_mode);
    try send(&DRAW);
    var x: usize = 0;
    while (x < 512) : (x += 1) {
        try send(&[2]u8{ CONTROL_DATA, 0x0 });
    }
}

pub fn send(bytes: []const u8) !void {
    const a: i2c.Address = @enumFromInt(ADDRESS);
    _ = i2c0.write_blocking(a, bytes) catch {
        led.put(1);
    };
}

pub fn send_data(data: u8) !void {
    const a: i2c.Address = @enumFromInt(ADDRESS);
    const DATA = [1]u8{CONTROL_DATA};
    _ = i2c0.write_blocking(a, &DATA) catch {
        led.put(1);
    };
    var page_buffer: [28]u8 = undefined;
    @memset(&page_buffer, data);
    _ = i2c0.write_blocking(a, &page_buffer) catch {
        led.put(1);
    };
}
