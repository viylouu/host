#version 460 core

uniform sampler2D atlas;

in vec2 uv;

out vec4 fCol;

void main() {
    vec2 texCoords = vec2(uv/16. + 15/16.);
    vec4 samp = texture(atlas, texCoords);
    if (samp.a < 0.1) {
        discard;
    }
    fCol = samp;
}
