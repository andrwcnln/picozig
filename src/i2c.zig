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
const DISPLAY_OFF: u8 = 0xAE;
const SET_DISPLAY_CLOCK_DIV: u8 = 0xD5;
const SET_MULTIPLEX: u8 = 0xA8;
const SET_DISPLAY_OFFSET: u8 = 0xD3;
const SET_START_LINE: u8 = 0x40;
const CHARGE_PUMP: u8 = 0x8D;
const MEMORY_MODE: u8 = 0x20;
const SEGREMAP: u8 = 0xA0;
const COMSCANDEC: u8 = 0xC8;
const SET_COMPINS: u8 = 0xDA;
const SET_CONSTRAST: u8 = 0xDA;
const SET_PRECHARGE: u8 = 0xD9;
const SET_VCOMDETECT: u8 = 0xDB;
const SET_DISPLAY_ALLON_RESUME: u8 = 0xA4;
const SET_NORMAL_DISPLAY: u8 = 0xA6;
const COMMAND_COLUMN_ADDRESS = 0x21;
const COMMAND_PAGE_ADDRESS = 0x22;

const INIT = [_]u8{
    DISPLAY_OFF,
    SET_DISPLAY_CLOCK_DIV,
    0x80,
    SET_MULTIPLEX,
    0x1F,
    SET_DISPLAY_OFFSET,
    0x00,
    SET_START_LINE | 0x00,
    CHARGE_PUMP,
    0x10,
    MEMORY_MODE,
    0x00,
    SEGREMAP | 0x01,
    COMSCANDEC,
    SET_COMPINS,
    0x02,
    SET_CONSTRAST,
    0x8F,
    SET_PRECHARGE,
    0x22,
    SET_VCOMDETECT,
    0x40,
    SET_DISPLAY_ALLON_RESUME,
    SET_NORMAL_DISPLAY,
};

const DRAW = [_]u8{
    COMMAND_COLUMN_ADDRESS,
    0x00,
    0x01,
    COMMAND_PAGE_ADDRESS,
    0x00,
    0x01,
};

pub fn main() !void {
    led.set_function(.sio);
    led.set_direction(.out);
    led.put(0);

    _ = i2c0.apply(.{
        .clock_config = rp2040.clock_config,
        .scl_pin = gpio.num(21),
        .sda_pin = gpio.num(20),
        .baud_rate = 400000,
    });

    time.sleep_ms(1000);

    try send_command(&INIT);

    time.sleep_ms(10000);
    led.put(1);
    time.sleep_ms(1000);
    led.put(0);

    try send_command(&DRAW);
    try send_data();
}

pub fn send_command(bytes: []const u8) !void {
    const a: i2c.Address = @enumFromInt(ADDRESS);
    for (bytes) |byte| {
        const command = [_]u8{ CONTROL_COMMAND, byte };
        _ = i2c0.write_blocking(a, &command) catch {
            led.put(1);
        };
    }
}
pub fn send_data() !void {
    const a: i2c.Address = @enumFromInt(ADDRESS);
    const DATA = [1]u8{CONTROL_DATA};
    _ = i2c0.write_blocking(a, &DATA) catch {
        led.put(1);
    };
    const page_buffer = [_]u8{ 0xFF, 0xFF };
    _ = i2c0.write_blocking(a, &page_buffer) catch {
        led.put(1);
    };
}
