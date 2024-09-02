// Inspired by Starry planes - Created by mrange
#define TIME        iTime
#define RESOLUTION  iResolution
#define ROTATE(angle) mat2(cos(angle), sin(angle), -sin(angle), cos(angle))

const float PI = acos(-1.0);
const float TAU = 2.0 * PI;
const float PLANE_DISTANCE = 0.5;
const float FURTHEST_DISTANCE = 16.0;
const float FADE_START = 8.0;

const vec2 PATH_A = vec2(0.31, 0.41);
const vec2 PATH_B = vec2(1.0, sqrt(0.5));

const vec4 U = vec4(0.0, 1.0, 2.0, 3.0);

vec3 acesApprox(vec3 color) {
    color = max(color, 0.0);
    color *= 0.6;
    const float a = 2.51;
    const float b = 0.03;
    const float c = 2.43;
    const float d = 0.59;
    const float e = 0.14;
    return clamp((color * (a * color + b)) / (color * (c * color + d) + e), 0.0, 1.0);
}

vec3 getOffset(float z) {
    return vec3(PATH_B * sin(PATH_A * z), z);
}

vec3 getOffsetDerivative(float z) {
    return vec3(PATH_A * PATH_B * cos(PATH_A * z), 1.0);
}

vec3 getOffsetSecondDerivative(float z) {
    return vec3(-PATH_A * PATH_A * PATH_B * sin(PATH_A * z), 0.0);
}

vec4 alphaBlend(vec4 background, vec4 foreground) {
    float alpha = foreground.w + background.w * (1.0 - foreground.w);
    vec3 color = (foreground.rgb * foreground.w + background.rgb * background.w * (1.0 - foreground.w)) / alpha;
    return alpha > 0.0 ? vec4(color, alpha) : vec4(0.0);
}

float circleDistance(vec2 point, float radius) {
    return length(point) - radius;
}

vec3 getNeonPalette(float n) {
    return 0.61 + 0.5 * sin(vec3(0.604, 0.122, 1.0) * n + vec3(0.890, 0.341, 1.0));
}

vec4 computePlaneColor(vec3 ro, vec3 rd, vec3 planePoint, vec3 nearPlanePoint, float planeDistance, vec3 colorPoint, vec3 offset, float noiseFactor) {
    float distanceAdjustment = 3.0 * planeDistance * distance(planePoint.xy, nearPlanePoint.xy);
    vec4 color = vec4(0.0);
    
    vec2 adjustedPoint = planePoint.xy - getOffset(planePoint.z).xy;
    vec2 offsetDerivative = getOffsetDerivative(planePoint.z).xz;
    vec2 offsetSecondDerivative = getOffsetSecondDerivative(planePoint.z).xz;
    float angleAdjustment = dot(offsetDerivative, offsetSecondDerivative);
    adjustedPoint *= ROTATE(angleAdjustment * PI * 5.0);

    float distToCircle = circleDistance(adjustedPoint, 0.45 + 0.1 * sin(TIME * 2.0 + planePoint.z)) - 0.02;
    float innerDistToCircle = distToCircle - 0.01;
    float distToCenter = length(adjustedPoint);

    const float colorPeriod = PI * 100.0;
    float colorAdjustment = distanceAdjustment * 200.0;

    color.rgb = getNeonPalette(0.5 * noiseFactor + 2.0 * distToCenter) *
                mix(0.5 / (distToCenter * distToCenter), 1.0, smoothstep(-0.5 + colorAdjustment, 0.5 + colorAdjustment, sin(distToCenter * colorPeriod))) /
                max(3.0 * distToCenter * distToCenter, 1e-1);
                
    color.rgb = mix(color.rgb, vec3(2.0), smoothstep(distanceAdjustment, -distanceAdjustment, innerDistToCircle));
    color.w = smoothstep(distanceAdjustment, -distanceAdjustment, -distToCircle);

    float glow = smoothstep(0.05, 0.2, -distToCircle);
    color.rgb += glow * vec3(0.412,0.678,0.925);

    return color;
}

vec3 computeColor(vec3 ww, vec3 uu, vec3 vv, vec3 ro, vec2 fragCoordNormalized) {
    float lp = length(fragCoordNormalized);
    vec2 np = fragCoordNormalized + 1.0 / RESOLUTION.xy;
    float perspectiveDepth = 2.0 - 0.25;
    
    vec3 rd = normalize(fragCoordNormalized.x * uu + fragCoordNormalized.y * vv + perspectiveDepth * ww);
    vec3 nrd = normalize(np.x * uu + np.y * vv + perspectiveDepth * ww);

    float nz = floor(ro.z / PLANE_DISTANCE);

    vec4 accumulatedColor = vec4(0.0);

    vec3 currentRo = ro;
    float accumulatedPlaneDistance = 0.0;

    for (float i = 1.0; i <= FURTHEST_DISTANCE; ++i) {
        if (accumulatedColor.w > 0.95) {
            break;
        }
        
        float planeZ = PLANE_DISTANCE * nz + PLANE_DISTANCE * i;

        float lpd = (planeZ - currentRo.z) / rd.z;
        float npd = (planeZ - currentRo.z) / nrd.z;
        float cpd = (planeZ - currentRo.z) / ww.z;

        vec3 planePoint = currentRo + rd * lpd;
        vec3 nearPlanePoint = currentRo + nrd * npd;
        vec3 colorPoint = currentRo + ww * cpd;

        accumulatedPlaneDistance += lpd;

        vec3 offset = getOffset(planePoint.z);

        float distanceFromStart = planePoint.z - ro.z;
        float fadeIn = smoothstep(PLANE_DISTANCE * FURTHEST_DISTANCE, PLANE_DISTANCE * FADE_START, distanceFromStart);
        float fadeOut = smoothstep(0.0, PLANE_DISTANCE * 0.1, distanceFromStart);
        float fadeOutRI = smoothstep(0.0, PLANE_DISTANCE * 1.0, distanceFromStart);

        float fade = mix(1.0, 0.9, fadeOutRI * fadeIn);

        vec4 planeColor = computePlaneColor(ro, rd, planePoint, nearPlanePoint, accumulatedPlaneDistance, colorPoint, offset, nz + i);

        planeColor.w *= fadeOut * fadeIn;
        accumulatedColor = alphaBlend(planeColor, accumulatedColor);
        currentRo = planePoint;
    }

    return accumulatedColor.rgb * accumulatedColor.w;
}

void drawFigurine(inout vec4 fragColor, vec2 uv) {
    float scale = 1.05; 

    float angle = TIME * 1.0; 

    mat2 rotation = ROTATE(angle);

    vec2 bodyPos = vec2(0.0, 0.0); 
    vec2 headPos = rotation * (vec2(0.0, 0.1) * scale) + bodyPos;
    float head = smoothstep(0.03, 0.025, length(uv - headPos) / scale);

    vec2 bodyCenter = rotation * (vec2(0.0, -0.05) * scale) + bodyPos;
    float body = smoothstep(0.07, 0.06, length(uv - bodyCenter) / scale);

    float legSwing = 0.03 * sin(TIME * 1.0);
    vec2 legOffset = vec2(0.0, -0.15) * scale;
    vec2 leg1Pos = rotation * (bodyCenter + legOffset + vec2(legSwing, 0.05 * cos(TIME * 5.0)) * scale);
    vec2 leg2Pos = rotation * (bodyCenter + legOffset + vec2(-legSwing, -0.05 * cos(TIME * 5.0)) * scale);
    float leg1 = smoothstep(0.025, 0.02, length(uv - leg1Pos) / scale);
    float leg2 = smoothstep(0.025, 0.02, length(uv - leg2Pos) / scale);

    float armSwing = 0.06 * cos(TIME * 1.0);
    vec2 armOffset = vec2(0.0, -0.02) * scale;
    vec2 arm1Pos = rotation * (bodyCenter + armOffset + vec2(armSwing, 0.06 * sin(TIME * 5.0)) * scale);
    vec2 arm2Pos = rotation * (bodyCenter + armOffset + vec2(-armSwing, -0.06 * sin(TIME * 5.0)) * scale);
    float arm1 = smoothstep(0.02, 0.015, length(uv - arm1Pos) / scale);
    float arm2 = smoothstep(0.02, 0.015, length(uv - arm2Pos) / scale);

    float figurine = max(body, max(head, max(leg1, max(leg2, max(arm1, arm2)))));
    vec3 figurineColor = vec3(0.000,0.000,0.000); 
    fragColor = mix(fragColor, vec4(figurineColor, 1.0), figurine);
}

void mainImage(out vec4 fragColor, in vec2 fragCoord) {
    vec2 resolution = RESOLUTION.xy;
    vec2 fragCoordNormalized = fragCoord / resolution;
    vec2 fragCoordCentered = -1.0 + 2.0 * fragCoordNormalized;
    fragCoordCentered.x *= resolution.x / resolution.y;

    float time = PLANE_DISTANCE * TIME;

    vec3 ro = getOffset(time);
    vec3 dro = getOffsetDerivative(time);
    vec3 ddro = getOffsetSecondDerivative(time);

    vec3 ww = normalize(dro);
    vec3 uu = normalize(cross(U.xyx + ddro, ww));
    vec3 vv = cross(ww, uu);

    vec3 finalColor = computeColor(ww, uu, vv, ro, fragCoordCentered);
    finalColor = acesApprox(finalColor);
    finalColor = sqrt(finalColor);

    finalColor.g = 0.1;
    
    fragColor = vec4(finalColor, 1.0);
    
    drawFigurine(fragColor, fragCoordCentered); 
}
