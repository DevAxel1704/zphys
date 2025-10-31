const math = @import("math");

/// This function will only work for convex polygon -> for non convex we would need to do an specialized function
/// that returns bigger array
/// Implements sutherland-hodgman algorithm to clip one polygon against another by
/// iteratively clipping against each edge
/// output size n + m -> maximum output size of clipped convex polygon
///     - Each of the clipping planes can, at most, add one new vertex to the convex polygon,
///     - and this process repeats M times, leading to a maximum of N+M vertices.
pub fn clipPolyPoly(comptime n: usize, poly_to_clip: *const [n]math.Vec3,
    comptime m: usize, clipping_poly: *const [m]math.Vec3,
    normal:math.Vec3,
    out_poly:*[n + m]math.Vec3) []math.Vec3 {

    var buffer : [n + m]math.Vec3 = undefined;
    
    // Initialize first buffer with input polygon
    for (poly_to_clip, 0..) |vertex, idx| {
        out_poly[idx] = vertex;
    }
    var current_len: usize = poly_to_clip.len;
    
    var i:u32 = 0;
    while (i < clipping_poly.len) : (i += 1){
        const vertex1 = clipping_poly[i];
        const vertex2 = clipping_poly[(i + 1) % clipping_poly.len];
        const clip_normal = normal.cross(vertex2.sub(&vertex1));

        // Double buffering: swap between out_poly and buffer
        if (i % 2 == 0) {
            current_len = clipPolyPlane(out_poly[0..current_len], vertex1, clip_normal, &buffer);
        } else {
            current_len = clipPolyPlane(buffer[0..current_len], vertex1, clip_normal, out_poly);
        }
        
        if (current_len == 0) {
            return out_poly[0..0];
        }
    }
    
    if (clipping_poly.len % 2 == 0) {
        for (buffer[0..current_len], 0..) |vertex, idx| {
            out_poly[idx] = vertex;
        }
    }
    
    return out_poly[0..current_len];
}

fn clipPolyPlane(poly_to_clip: []const math.Vec3, plane_origin: math.Vec3, plane_normal : math.Vec3, out_poly: []math.Vec3) usize {
    var prev_vertex = poly_to_clip[poly_to_clip.len - 1];
    var prev_num = (plane_origin - prev_vertex).dot(plane_normal);
    var prev_inside = prev_num < 0;

    var i:u32 = 0;
    var out_len: u32 = 0;
    while (i < poly_to_clip.len) : (i += 1) {
        const cur_vertex =  poly_to_clip[i];
        const cur_num = (plane_origin - cur_vertex).dot(plane_normal);
        const cur_inside = cur_num < 0;

        if (cur_inside != prev_inside) {
            const cur_prev = cur_vertex - prev_vertex;
            const denom = cur_prev.dot(plane_normal);
            if (denom != 0) {
                out_poly[out_len] = prev_vertex.add(&cur_prev.mulScalar(prev_num/denom));
                out_len += 1;
            }
            else {
                cur_inside = prev_inside; // edge is parallel to plane, treat point as if it were on the same side as the last point
            }
        }

        if (cur_inside){
            out_poly[out_len] = cur_vertex;
            out_len += 1;
            prev_inside = true;
        }

        prev_vertex = cur_vertex;
        prev_num = cur_num;
        prev_inside = cur_inside;
    }
    
    return out_len;
}
