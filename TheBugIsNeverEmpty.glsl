void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
    vec2 uv = (fragCoord.xy / iResolution.xy) * 2.0 - 1.0;
    uv.x *= iResolution.x / iResolution.y;
    
    float time = iTime * 0.5;
    
    float radius = 0.5;
    float distToCircle = length(uv) - radius;

    float angle = sin(uv.y * 7. + time) * sin(uv.x * 3.0 + time);
    vec2 flow = vec2(cos(angle), sin(angle));
    
    float inkNoise = cos(uv.x * 10.0 + time) * cos(uv.y * 10.0 + time * 1.2);
    inkNoise *= smoothstep(0.0, 0.1, abs(distToCircle));

    float inkyEdge = smoothstep(0.02, 0.0, abs(distToCircle - 0.02)) + inkNoise * 0.2;

    float inkFlow = smoothstep(0.7, 0.0, distToCircle) * tan(dot(uv + flow, vec2(4.0, 3.0)));
    float inkSmear = smoothstep(0.0955, 0.0, distToCircle - inkFlow * 0.1);

    float finalInk = inkyEdge + inkSmear * 0.6;
    finalInk *= smoothstep(0.5, 0.0, distToCircle * 2.0); 
    fragColor = vec4(vec3(1.)-vec3(finalInk), .6);
}
