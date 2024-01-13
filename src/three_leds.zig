const std = @import("std");
const microzig = @import("microzig");
const rp2040 = microzig.hal;
const gpio = rp2040.gpio;
const clocks = rp2040.clocks;
const time = rp2040.time;

const pin_config = rp2040.pins.GlobalConfiguration{
    .GPIO18 = .{ .name = "led1", .direction = .out },
    .GPIO19 = .{ .name = "led2", .direction = .out },
    .GPIO20 = .{ .name = "led3", .direction = .out },
};

pub fn main() !void {
    const pins = pin_config.apply();

    while (true) {
        pins.led1.toggle();
        time.sleep_ms(250);
        pins.led2.toggle();
        time.sleep_ms(250);
        pins.led3.toggle();
        time.sleep_ms(250);
    }
}
