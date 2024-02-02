const std = @import("std");
const microzig = @import("microzig");

const rp2040 = microzig.hal;
const i2c = rp2040.i2c;
const gpio = rp2040.gpio;
const time = rp2040.time;

const i2c0 = i2c.num(0);
const led = gpio.num(25);

pub fn main() !void {
    led.set_function(.sio);
    led.set_direction(.out);
    led.put(1);

    _ = i2c0.apply(.{
        .clock_config = rp2040.clock_config,
        .scl_pin = gpio.num(4),
        .sda_pin = gpio.num(5),
        .baud_rate = 400000,
    });

    time.sleep_ms(1000);

    const a: i2c.Address = @enumFromInt(60);

    var tx_data: []u8 = "test";
    _ = i2c0.write_blocking(a, tx_data) catch {
        panic("aaaahh");
    };
}
