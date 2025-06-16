#version 430 core

layout(binding = 0, std430) readonly buffer SSBO {
    int data[];
};

const vec3 facePosses[] = vec3[](
    vec3(0,0,0), vec3(0,1,0), vec3(1,1,0), vec3(1,1,0), vec3(1,0,0), vec3(0,0,0)
);

uniform int vertices;
uniform vec3 chunkPos;
uniform mat4 proj;

out float dist;
out vec2 uv;

vec2 isometricize(vec3 pos) {
    return vec2(-pos.x*6/16. +pos.z*6/16., -pos.y*6/16. +pos.z*3/16. +pos.x*3/16.);
}

void main() {
    int index = gl_VertexID / 6;
    int packdata = data[index];
    int cVertexID = gl_VertexID % 6;

    int x = (packdata) & 0x1F;
    int y = (packdata >> 5) & 0x1F;
    int z = (packdata >> 10) & 0x1F;
    vec3 pos = vec3(x,y,z);

    vec2 isoblock = isometricize(pos);
    vec2 isochunk = isometricize(chunkPos*32);
    vec2 iso = isoblock + isochunk;
    vec2 pixel = iso + (facePosses[cVertexID].xy - vec2(.5)) + vec2(320/16.,180/16.);
    vec2 ndc = vec2(
        (float(pixel.x) / (640./16.)) * 2 - 1,
        1 - (float(pixel.y) / (360./16.)) * 2
    );

    pos = vec3(ndc, 0);

    int uvo = (packdata >> 15) & 0xFF;
    uv = facePosses[cVertexID].xy + vec2(uvo & 0xF, (uvo>>4) & 0xF);

    dist = float(index) +(chunkPos.x +chunkPos.y +chunkPos.z)*32768;
    gl_Position = proj * vec4(pos.xy, dist, 1);
}
