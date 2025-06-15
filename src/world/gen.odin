package world

import noise "../../lib/fastnoiselite"

__worldnoise: noise.FNL_State

__seed: i32

init :: proc(seed: i32) {
    __seed = seed
    __worldnoise = noise.create_state(__seed)
}

gen_chunk :: proc() -> chunk {
    chunk_data: [32][32][32]blocktype//; defer free(&chunk_data)
    for y in 0..<32 { for x in 0..<32 { for z in 0..<32 { 
        chunk_data[x][y][z] = blocktype.air

        if noise.get_noise_2d(__worldnoise,f32(x),f32(z)) * 16 + 16 < f32(y) {
            chunk_data[x][y][z] = blocktype.stone
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
