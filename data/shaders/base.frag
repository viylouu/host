#version 430 core

uniform sampler2D atlas;
uniform sampler2D atlas_n;
uniform sampler2D atlas_h;
uniform sampler2D atlas_lut;
uniform sampler2D palette;

in vec2 uv;
in float dist;
flat in int neighx;
flat in int neighz;

out vec4 fCol;

void main() {
    vec2 texCoord = uv / 16.;
    vec4 samp = texture(atlas, texCoord);
    
    if (samp.a < 0.1) {
        discard;
    }

    vec4 neigh = texture(atlas_h, texCoord);
    if ((neigh.r > 0 && bool(neighx)) || (neigh.b > 0 && bool(neighz))) {
        vec4 lut = texture(atlas_lut, texCoord)*256;
        lut.r += 1;
        samp = texture(palette, vec2(lut.r /241., 0));
    }

    fCol = samp;
}
