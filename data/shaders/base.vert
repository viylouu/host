#version 430 core

struct vtxData {
    int low;
    int high;
};

layout(binding = 0, std430) readonly buffer SSBO {
    vtxData data[];
};

const vec3 facePosses[] = vec3[](
    vec3(0,0,0), vec3(0,1,0), vec3(1,1,0), vec3(1,1,0), vec3(1,0,0), vec3(0,0,0)
);

uniform int vertices;
uniform vec3 chunkPos;
uniform mat4 proj;

out float dist;
out vec2 uv;
flat out int neighx;
flat out int neighz;

vec2 isometricize(vec3 pos) {
    return vec2(-pos.x*6/16. +pos.z*6/16., -pos.y*6/16. +pos.z*3/16. +pos.x*3/16.);
}

void main() {
    int index = gl_VertexID / 6;
    vtxData packdata = data[index];
    int cVertexID = gl_VertexID % 6;

    int x = (packdata.low) & 0x1F;
    int y = (packdata.low >> 5) & 0x1F;
    int z = (packdata.low >> 10) & 0x1F;
    vec3 pos = vec3(x,y,z);

    vec2 isoblock = isometricize(pos);
    vec2 isochunk = isometricize(chunkPos*32);
    vec2 iso = isoblock + isochunk;
    vec2 pixel = iso + (facePosses[cVertexID].xy - vec2(.5)) + vec2(160/16.,90/16.);
    vec2 ndc = vec2(
        (float(pixel.x) / (320./16.)) * 2 - 1,
        1 - (float(pixel.y) / (180./16.)) * 2
    );

    pos = vec3(ndc, 0);

    int uvo = (packdata.low >> 15) & 0xFF;
    uv = facePosses[cVertexID].xy + vec2(uvo & 0xF, (uvo>>4) & 0xF);

    dist = (x+y+z) +(chunkPos.x +chunkPos.y +chunkPos.z)*32768;
    gl_Position = proj * vec4(pos.xy, dist, 1);

    int nx = (packdata.high) & 0x1;
    int nz = (packdata.high >> 1) & 0x1;

    neighx = nx;
    neighz = nz;
}
