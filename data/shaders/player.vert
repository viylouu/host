#version 430 core

const vec2 facePosses[] = vec2[](
    vec2(0,0), vec2(0,1), vec2(1,1), vec2(1,1), vec2(1,0), vec2(0,0)
);

uniform vec3 pos;
uniform mat4 proj;

vec2 isometricize(vec3 pos) {
    return vec2(-pos.x*6/16. +pos.z*6/16., -pos.y*6/16. +pos.z*3/16. +pos.x*3/16.);
}

out vec2 uv;

void main() {
    vec2 fpos = facePosses[gl_VertexID];
    vec2 iso = isometricize(pos);
    vec2 pixel = iso + (fpos.xy - vec2(.5)) + vec2(160/16.,90/16.);
    vec2 ndc = vec2(
        (float(pixel.x) / (320./16.)) * 2 - 1,
        1 - (float(pixel.y) / (180./16.)) * 2
    );

    float dist = pos.x + pos.y*1024 + pos.z*32;
    gl_Position = proj * vec4(ndc, dist, 1);
    uv = fpos;
}
