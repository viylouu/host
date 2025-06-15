#version 430 core

layout(binding = 0, std430) readonly buffer SSBO {
    int data[];
};

const vec3 facePosses[] = vec3[](
    vec3(0,0,0), vec3(0,1,0), vec3(1,1,0), vec3(1,1,0), vec3(1,0,0), vec3(0,0,0)
);

out vec2 uv;

void main() {
    int index = gl_VertexID / 6;
    int packdata = data[index];
    int cVertexID = gl_VertexID % 6;

    int x = (packdata) & 0x1F;
    int y = (packdata >> 5) & 0x1F;
    int z = (packdata >> 10) & 0x1F;
    vec3 pos = vec3(x,y,z);

    pos += facePosses[cVertexID];

    uv = facePosses[cVertexID].xy;

    gl_Position = vec4(pos.xy - vec2(.5), 0,1);
}
