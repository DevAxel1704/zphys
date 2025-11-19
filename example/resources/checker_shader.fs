#version 330

// Input attributes (from vertex shader)
in vec2 fragTexCoord;
in vec4 fragColor;
in vec3 fragNormal;
in vec3 fragPosition;

// Output color
out vec4 finalColor;

// Uniforms
uniform vec4 colDiffuse;   // Color A (White checks)
uniform vec4 colSecondary; // Color B (Dark/Yellow checks)

// Light information (Simplified for this example)
// Use Directional light (Sun) instead of point light
const vec3 lightDir = normalize(vec3(0.5, 1.0, 0.5)); 
const vec3 lightColor = vec3(1.0, 1.0, 1.0);
const float ambientStrength = 0.6; // Increased ambient for brighter overall look
const float specularStrength = 0.1;

void main()
{
    // Checkerboard Pattern
    vec2 tex = fragTexCoord * 1.0; // Scale if needed, but UVs usually sufficient
    vec2 less_half_vec = step(vec2(0.5), fract(tex));
    bool is_white = (less_half_vec.x == less_half_vec.y);
    
    float darken_factor = is_white ? 1.0 : 0.5;
    
    // Anti-aliasing for checkerboard (derivatives)
    vec2 dx = dFdx(fragTexCoord);
    vec2 dy = dFdy(fragTexCoord);
    float texel_distance = sqrt(dot(dx, dx) + dot(dy, dy));
    
    // Fade out pattern when it tiles too often (distance based)
    // Mix factor: 1.0 for white check, 0.0 for other check.
    float mixFactor = is_white ? 1.0 : 0.0;
    
    // Jolt logic adapted: Blur towards 0.5 (average of two colors)
    float blur = clamp(5.0 * texel_distance - 1.5, 0.0, 1.0);
    mixFactor = mix(mixFactor, 0.5, blur);

    // Mix between Secondary and Diffuse color
    vec3 objectColor = mix(colSecondary.rgb, colDiffuse.rgb, mixFactor);
    
    // Basic Lighting (Phong)
    
    // Ambient
    vec3 ambient = ambientStrength * lightColor;
    
    // Diffuse
    vec3 norm = normalize(fragNormal);
    // lightDir is already defined as const
    float diff = max(dot(norm, lightDir), 0.0);
    vec3 diffuse = diff * lightColor;
    
    // Combine
    // If using vertex colors, multiply by fragColor.rgb
    objectColor *= fragColor.rgb;
    
    vec3 result = (ambient + diffuse) * objectColor;
    
    // Gamma Correction (Linear -> sRGB)
    result = pow(result, vec3(1.0 / 2.2));
    
    finalColor = vec4(result, colDiffuse.a * fragColor.a); // Use Primary Alpha
}
