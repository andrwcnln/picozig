This repository contains some code that I wrote for my Raspberry Pi Pico, using [Microzig](https://github.com/ZigEmbeddedGroup/microzig). The code here is slightly modified code form the [official Microzig examples](https://github.com/ZigEmbeddedGroup/microzig-examples).

The files in the `src` directory do the following:
- `three_leds.zig`: toggle three LEDs connected to GPIO18-20 (they don't have to be LEDs, that's just what I used)
- `i2c.zig`: a basic driver for sending data over I2C to an SDD1306 OLED display

# Build
Clone the repository
```
$ git clone https://github.com/andrwcnln/picozig
```
Build the files by running `zig build` at the root of the project
```
$ zig build
```
The files will be in `$PROJECT_ROOT/zig-out/firmware`

# Run
Just copy the desired `.uf2` file over to your Raspberry Pi Pico when connected in BOOTSEL mode.
