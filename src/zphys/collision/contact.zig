const math = @import("math");

pub const Contact = struct {
    body_a: u32,
    body_b: u32,
    normal: math.Vec3,
    point: math.Vec3,
    penetration: f32,
    friction: f32,
    restitution: f32,
};

pub const ContactManifold = struct {
    body_a: u32,
    boody_b: u32,
    normal: math.vec3,
    penetration_depth: f32,

    // to decrease cache missed and improve memory footprint it might be a good idea to separate contact and points information
    relative_contact_poinit_on_a: []math.vec3,
    relative_contact_point_on_b: []math.vec3,
};
