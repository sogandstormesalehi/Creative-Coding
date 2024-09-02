#define FAR 50.0
#define CAMERA_SPEED 2.0

float map(in vec3 p) {
    vec3 ip = floor(p) + 0.5;
    p -= ip;
    
    vec3 q = abs(p);
    q = step(q.yzx, q.xyz) * step(q.zxy, q.xyz) * sign(p);
    q.x = fract(sin(mod(dot(ip + q * 0.5, vec3(157.31, 211.67, 81.23)), 6.2831)) * 43758.5453);
    
    float spiralRadius = 0.5 + 0.3 * sin(iTime + length(ip.xy));
    p.xy = abs(q.x > 0.333 ? q.x > 0.666 ? p.xz : p.yz : p.xy);
    float distance = max(p.x, p.y) - spiralRadius;
    
    distance += 0.05 * sin(8.0 * atan(p.y, p.x) + iTime);
    return distance;
}

float trace(vec3 ro, vec3 rd) {
    float t = 0.0;
    for (int i = 0; i < 72; i++) {
        float d = map(ro + rd * t);
        if (abs(d) < 0.002 * (t * 0.05 + 1.0) || t > FAR) break;
        t += d;
    }
    return min(t, FAR);
}

vec3 normal(in vec3 p) {
    vec2 e = vec2(0.01, 0);
    return normalize(vec3(
        map(p + e.xyy) - map(p - e.xyy),
        map(p + e.yxy) - map(p - e.yxy),
        map(p + e.yyx) - map(p - e.yyx)
    ));
}

float shadow(vec3 ro, vec3 rd) {
    float t = 0.02;
    float shadowFactor = 1.0;
    for (int i = 0; i < 16; i++) {
        float h = map(ro + rd * t);
        shadowFactor = min(shadowFactor, 10.0 * h / t);
        if (h < 0.001) break;
        t += h;
    }
    return clamp(shadowFactor, 0.0, 1.0);
}

vec3 avoidCollision(vec3 ro, vec3 rd, float speed) {
    float t = 0.0;
    for (int i = 0; i < 72; i++) {
        float d = map(ro + rd * t);
        if (d < 0.1) {  // If too close to an object, reduce movement
            speed *= 0.5;
            if (speed < 0.01) break;  // Stop if the movement becomes negligible
        }
        t += d;
    }
    return ro + rd * speed;
}

void mainImage(out vec4 fragColor, in vec2 fragCoord) {
    vec3 ro = vec3(0, 0, iTime * CAMERA_SPEED);
    vec3 rd = normalize(vec3(2.0 * fragCoord - iResolution.xy, iResolution.y));
    
    rd.xy *= mat2(cos(iTime), -sin(iTime), sin(iTime), cos(iTime));
    rd.xz *= mat2(cos(iTime * 0.5), -sin(iTime * 0.5), sin(iTime * 0.5), cos(iTime * 0.5));
    
    ro = avoidCollision(ro, vec3(0, 0, 1), CAMERA_SPEED);

    float t = trace(ro, rd);
    vec3 p = ro + rd * t;
    
    vec3 n = normal(p);
    
    vec3 lightDir = normalize(vec3(0.3, 0.4, 0.7));
    vec3 viewDir = normalize(ro - p);
    
    float ambient = 0.2;
    float diffuse = max(dot(n, lightDir), 0.0);
    float specular = pow(max(dot(reflect(-lightDir, n), viewDir), 0.0), 16.0);
    
    float shadowFactor = shadow(p + n * 0.01, lightDir);
    
    vec3 baseColor = mix(vec3(0.1, 0.3, 0.6), vec3(0.8, 0.4, 1.0), dot(n, vec3(0.577)));
    vec3 lighting = (ambient + shadowFactor * (diffuse + specular)) * baseColor;
    
    lighting += 0.2 * sin(10.0 * p.x + iTime) * sin(10.0 * p.y + iTime) * sin(10.0 * p.z + iTime);
    
    fragColor = vec4(lighting, 1.0);
}
