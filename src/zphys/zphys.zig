pub const World = @import("world.zig").World;
pub const Body = @import("body.zig").Body;
pub const BodyDef = @import("body.zig").BodyDef;

pub const shape = @import("collision/shape.zig");

const std = @import("std");

test {
    std.testing.refAllDeclsRecursive(@This());
}

