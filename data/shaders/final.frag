#version 330 core

uniform sampler2D screen;

in vec2 uv;

out vec4 fCol;

void main() {
    //fCol = texture(screen, uv);
    //fCol = vec4(uv,0,1);
    fCol = vec4(1);
}
