package world

import noise "../../lib/fastnoiselite"

__surfnoise: noise.FNL_State
__stonenoise: noise.FNL_State

__seed: i32

init :: proc(seed: i32) {
    __seed = seed
    __surfnoise = noise.create_state(__seed)
    __stonenoise = noise.create_state(__seed-1)

    __surfnoise.frequency = 0.03
    __stonenoise.frequency = 0.1
}

gen_chunk :: proc() -> chunk {
    chunk_data: [32][32][32]blocktype//; defer free(&chunk_data)
    for y in 0..<32 { for x in 0..<32 { for z in 0..<32 { 
        chunk_data[x][y][z] = blocktype.air

        if noise.get_noise_2d(__surfnoise,f32(x),f32(z)) * 4 + 16 > f32(y) {
            chunk_data[x][y][z] = blocktype.grass
        } else { continue }
        if noise.get_noise_2d(__surfnoise,f32(x),f32(z)) * 4 + 16 > f32(y)+1 {
            chunk_data[x][y][z] = blocktype.dirt
        }

        //if noise.get_noise_2d(__stonenoise,f32(x),f32(z)) * 3 + 4 < f32(y) {
        //    chunk_data[x][y][z] = blocktype.stone
        //}

        if chunk_data[x][y][z] != blocktype.air {
            chunk_data[x][y][z] = blocktype.box
        }
    }}}

    chunk_verts, chunk_vao, chunk_ssbo := mesh_chunk(chunk_data)

    return chunk {
        mesh = chunk_verts,
        data = chunk_data,
        vao  = chunk_vao,
        ssbo = chunk_ssbo
    }
}
