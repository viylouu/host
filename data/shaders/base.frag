#version 430 core

uniform sampler2D atlas;

in vec2 uv;

out vec4 fCol;

void main() {
    vec4 samp = texture(atlas, ( uv )/16.);
    if (samp.a < 0.1) {
        discard;
    }

    fCol = samp;
}
