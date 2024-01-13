const std = @import("std");
const rp2040 = @import("rp2040");

const available_sources = [_]Source{
    .{ .name = "pico_three_leds", .target = rp2040.boards.raspberry_pi.pico, .file = "src/three_leds.zig" },
};

pub fn build(b: *std.Build) void {
    const microzig = @import("microzig").init(b, "microzig");
    const optimize = b.standardOptimizeOption(.{});

    for (available_sources) |source| {
        // `addFirmware` basically works like addExecutable, but takes a
        // `microzig.Target` for target instead of a `std.zig.CrossTarget`.
        //
        // The target will convey all necessary information on the chip,
        // cpu and potentially the board as well.
        const firmware = microzig.addFirmware(b, .{
            .name = source.name,
            .target = source.target,
            .optimize = optimize,
            .source_file = .{ .path = source.file },
        });

        // `installFirmware()` is the MicroZig pendant to `Build.installArtifact()`
        // and allows installing the firmware as a typical firmware file.
        //
        // This will also install into `$prefix/firmware` instead of `$prefix/bin`.
        microzig.installFirmware(b, firmware, .{});

        // For debugging, we also always install the firmware as an ELF file
        microzig.installFirmware(b, firmware, .{ .format = .elf });
    }
}

const Source = struct {
    target: @import("microzig").Target,
    name: []const u8,
    file: []const u8,
};
