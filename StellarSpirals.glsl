precision highp float;

float gTime = 0.;
const float REPEAT = 5.0;

mat2 rot(float a) {
    float c = cos(a), s = sin(a);
    return mat2(c,s,-s,c);
}

float sdStar(vec3 p, float numPoints, float innerRadius, float outerRadius, float twist) {
    float angle = atan(p.y, p.x) * numPoints;
    float radius = length(p.xy);
    float star = abs(cos(angle + twist * p.z)) * (outerRadius - innerRadius) + innerRadius;
    return radius - star;
}

float spiralBox(vec3 pos, float scale, float twist) {
    float dynamicScale = scale * (1.0 + 0.5 * sin(gTime * 2.0 + length(pos.xy) * 5.0));
    pos *= dynamicScale;
    float base = sdStar(pos, 7.0 + 3.0 * sin(gTime * 3.0), 0.2, 0.4, twist) / 1.5;
    pos.xy *= 5.0;
    pos.y -= 3.5;
    pos.xy *= rot(0.75 + 0.3 * sin(gTime * 2.0));
    return -base;
}

float boxSet(vec3 pos, float iTime) {
    vec3 pos_origin = pos;
    
    pos.y += sin(gTime * 0.4) * 2.5;
    pos.xy *= rot(0.8 + 0.2 * cos(gTime * 3.0));
    float box1 = spiralBox(pos, 2.0 - abs(sin(gTime * 0.4)) * 1.5, gTime * 0.3);
    
    pos = pos_origin;
    pos.y -= sin(gTime * 0.4) * 2.5;
    pos.xy *= rot(0.8 + 0.2 * cos(gTime * 3.0));
    float box2 = spiralBox(pos, 2.0 - abs(sin(gTime * 0.4)) * 1.5, gTime * 0.3);
    
    pos = pos_origin;
    pos.x += sin(gTime * 0.4) * 2.5;
    pos.xy *= rot(0.8 + 0.2 * cos(gTime * 3.0));
    float box3 = spiralBox(pos, 2.0 - abs(sin(gTime * 0.4)) * 1.5, gTime * 0.3); 
    
    pos = pos_origin;
    pos.x -= sin(gTime * 0.4) * 2.5;
    pos.xy *= rot(0.8 + 0.2 * cos(gTime * 3.0));
    float box4 = spiralBox(pos, 2.0 - abs(sin(gTime * 0.4)) * 1.5, gTime * 0.3); 
    
    pos = pos_origin;
    pos.xy *= rot(0.8 + 0.2 * cos(gTime * 3.0));
    float box5 = spiralBox(pos, 0.5, gTime * 0.3) * 6.0;  
    
    pos = pos_origin;
    float box6 = spiralBox(pos, 0.5, gTime * 0.3) * 6.0;  
    
    return max(max(max(max(max(box1, box2), box3), box4), box5), box6);
}

float map(vec3 pos, float iTime) {
    return boxSet(pos, iTime);
}

void mainImage(out vec4 fragColor, in vec2 fragCoord) {
    vec2 p = (fragCoord.xy * 2.0 - iResolution.xy) / min(iResolution.x, iResolution.y);
    vec3 ro = vec3(0.0, -0.2, iTime * 4.0);
    vec3 ray = normalize(vec3(p, 1.5));
    
    ray.xy = ray.xy * rot(sin(iTime * 0.03) * 5.0 + 0.3 * sin(iTime * 8.0));
    ray.yz = ray.yz * rot(sin(iTime * 0.05) * 0.2 + 0.2 * cos(iTime * 7.0));
    
    float t = 0.1;
    vec3 col = vec3(0.0);
    float ac = 0.0;

    for (int i = 0; i < 99; i++) {
        vec3 pos = ro + ray * t;
        pos = mod(pos - 2.0, 4.0) - 2.0;
        gTime = iTime - float(i) * 0.01;
        
        float d = map(pos, iTime);
        d = max(abs(d), 0.01);
        ac += exp(-d * 23.0);
        t += d * 0.55;
    }

    col = vec3(ac * 0.02);

    col += vec3(0.5 * abs(sin(iTime * 3.0)), 0.2 * abs(cos(iTime * 2.0)), 0.5 + sin(iTime * 4.0) * 0.4);

    fragColor = vec4(col, 1.0 - t * (0.02 + 0.02 * sin(iTime * 5.0)));
}
