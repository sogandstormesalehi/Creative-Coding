// Simple 2D noise function
float noise(vec2 p) {
    return fract(sin(dot(p, vec2(127.1, 311.7))) * 43758.5453);
}

// Smooth noise
float smoothNoise(vec2 p) {
    vec2 i = floor(p);
    vec2 f = fract(p);
    f = f * f * (3.0 - 2.0 * f);
    return mix(mix(noise(i + vec2(0.0, 0.0)), noise(i + vec2(1.0, 0.0)), f.x),
               mix(noise(i + vec2(0.0, 1.0)), noise(i + vec2(1.0, 1.0)), f.x),
               f.y);
}

// Clouds function
float clouds(vec2 uv, float time) {
    uv *= 0.5;
    float n = smoothNoise(uv * 3.0 + time * 0.05);
    n += 0.5 * smoothNoise(uv * 6.0 + time * 0.1);
    n += 0.25 * smoothNoise(uv * 12.0 + time * 0.2);
    return n;
}

void mainImage(out vec4 fragColor, in vec2 fragCoord)
{
    vec2 uv = fragCoord / iResolution.xy;
    uv.y *= iResolution.y / iResolution.x;
    
    float time = iTime * 3.0; // Adjust time for faster movement
    
    // Create moving clouds
    float cloudLayer = clouds(uv, time);
    vec3 cloudColor = vec3(0.678,0.902,0.753) * smoothstep(0.4, 0.6, cloudLayer);
    
    // Scale down the entire figure to make it small
    float scale = 0.15;
    
    // Calculate mouse position normalized between 0 and 1
    vec2 mousePos = iMouse.xy / iResolution.xy;
    
    // If mouse is not clicked, keep it at the center
    if (iMouse.z <= 0.0) {
        mousePos = vec2(0.5, 0.4); // Default position when no mouse interaction
    }
    
    // Offset figure's position based on mouse movement
    vec2 bodyPos = mousePos + vec2(0.0, 0.02 * sin(time * 4.0));
    
    // Head
    vec2 headPos = bodyPos + vec2(0.0, 0.1) * scale;
    float head = smoothstep(0.03, 0.025, length(uv - headPos) / scale);
    
    // Body
    vec2 bodyCenter = bodyPos + vec2(0.0, -0.05) * scale;
    float body = smoothstep(0.07, 0.06, length(uv - bodyCenter) / scale);
    
    // Legs (behind the body)
    vec2 legOffset = vec2(0.0, -0.15) * scale;
    vec2 leg1Pos = bodyCenter + legOffset + vec2(0.03 * sin(time * 3.0), 0.05 * cos(time * 3.0)) * scale;
    vec2 leg2Pos = bodyCenter + legOffset + vec2(-0.03 * sin(time * 3.0), -0.05 * cos(time * 3.0)) * scale;
    float leg1 = smoothstep(0.025, 0.02, length(uv - leg1Pos) / scale);
    float leg2 = smoothstep(0.025, 0.02, length(uv - leg2Pos) / scale);
    
    // Arms
    vec2 armOffset = vec2(0.0, -0.02) * scale;
    vec2 arm1Pos = bodyCenter + armOffset + vec2(0.06 * cos(time * 3.0), 0.06 * sin(time * 3.0)) * scale;
    vec2 arm2Pos = bodyCenter + armOffset + vec2(-0.06 * cos(time * 3.0), -0.06 * sin(time * 3.0)) * scale;
    float arm1 = smoothstep(0.02, 0.015, length(uv - arm1Pos) / scale);
    float arm2 = smoothstep(0.02, 0.015, length(uv - arm2Pos) / scale);
    
    // Combine all parts to form the figure
    float figure = max(body, max(head, max(leg1, max(leg2, max(arm1, arm2)))));
    
    // Set the background color (including clouds)
    vec3 backgroundColor = mix(vec3(1.000,1.000,1.000), cloudColor, 0.5); // Light sky blue mixed with clouds
    
    // Final color output
    fragColor = vec4(mix(backgroundColor, vec3(0.0), figure), 1.0);
}
