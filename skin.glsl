float compute_color(float x, float t1, float t2, float t3, float scale1, float offset1, float scale2, float offset2) {
    if (x < t1) {
        return scale1 / 255.0;
    } else if (x < t2) {
        return (scale1 * x + offset1) / 255.0; 
    } else if (x < t3) {
        return (scale2 * x + offset2) / 255.0; 
    } else {
        return 1.0;
    }
}

float colormap_red(float x) {
    return compute_color(
        x,
        0.0,
        200400009.0 / 8297099.0,
        1.0,
        54.0,
        54.51,
        0.0,
        0.0
    );
}

float colormap_green(float x) {
    if (x < 20049.0 / 82979.0) {
        return 0.0; 
    }
    return compute_color(
        x,
        20049.0 / 82979.0,
        327013.0 / 810990.0,
        1.0,
        8546482679670.0 / 10875673217.0,
        -2064961390770.0 / 10875673217.0,
        103806720.0 / 483977.0,
        19607415.0 / 483977.0
    );
}

float colormap_blue(float x) {
    return compute_color(
        x,
        0.0,
        7249.0 / 82979.0,
        327013.0 / 810990.0,
        54.0,
        54.51,
        792.0,
        -64.36
    );
}

vec4 colormap(float x) {
    return vec4(
        colormap_red(x),
        colormap_green(x),
        colormap_blue(x),
        1.0
    );
}

float rand(vec2 n) { 
    return fract(sin(dot(n, vec2(12.9898, 4.1414))) * 43758.5453);
}

float noise(vec2 p){
    vec2 ip = floor(p);
    vec2 u = fract(p);
    u = u*u*(3.0-2.0*u);

    float res = mix(
        mix(rand(ip),rand(ip+vec2(1.0,0.0)),u.x),
        mix(rand(ip+vec2(0.0,1.0)),rand(ip+vec2(1.0,1.0)),u.x),u.y);
    return res*res;
}

const mat2 mtx = mat2( 0.80,  0.60, -0.60,  0.80 );

float fbm(vec2 p) {
    float f = 0.0;  
    float amp = 0.5; 
    float freq = 1.0; 
    for (int i = 0; i < 10; i++) {
        f += amp * noise(p * freq); 
        freq *= 2.0;               
        amp *= 0.5;                
    }
    return f;
}
float cosmic_flow(vec2 p) {
    float angle = sin(p.y);
    float radius = length(p);
    float spiral = sin(angle * 5.0 + radius * 4.0 - iTime) * 0.5 + 0.5;
    return fbm(p * 3.0 + vec2(cos(iTime), sin(iTime))) * spiral;
}

float temporal_waves(vec2 p) {
    return cos(p.y * 10.0 - iTime) * cos(p.x * 10.0 + iTime)* cos(p.x * 20.0 + iTime);
}

float abstract_pattern(vec2 p) {
    vec2 center = vec2(0.5, 0.5);
    vec2 pos = p - center;

    float flow = cosmic_flow(pos * 10.0);  
    float waves = temporal_waves(p * 2.0); 
    float fractal = fbm(p * 2.0 + flow * 1.9); 
    
    return mix(flow, fractal, 1.1) + waves * 0.1; 
}

void mainImage(out vec4 fragColor, in vec2 fragCoord) {
    vec2 uv = fragCoord / iResolution.xy;
    uv = uv - 1.0;
    uv.x *= iResolution.x / iResolution.y;

    float shade = abstract_pattern(uv);
    vec4 color = colormap(shade);
    fragColor = vec4(color.rgb, 1.0);
}
