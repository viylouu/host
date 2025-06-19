package world

import noise "../../lib/fastnoiselite"

__surfnoise: noise.FNL_State
__stonenoise: noise.FNL_State

__seed: i32

init :: proc(seed: i32) {
    __seed = seed
    __surfnoise = noise.create_state(__seed)
    __stonenoise = noise.create_state(__seed-1)

    __surfnoise.frequency = 0.04
    __surfnoise.fractal_type = noise.Fractal_Type.FBM
    __surfnoise.octaves = 3

    __stonenoise.frequency = 0.1
}

gen_chunk :: proc(i,j,k: int) -> chunk {
    chunk_data: [32][32][32]blocktype//; defer free(&chunk_data)

    surf2d: [32][32]f32
    for x in 0..<32 { for z in 0..<32 {
        surf2d[x][z] = noise.get_noise_2d(__surfnoise,f32(x +i*32),f32(z +k*32)) * 4 + 16
    }}

    for y in 0..<32 { for x in 0..<32 { for z in 0..<32 { 
        chunk_data[x][y][z] = blocktype.air

        if surf2d[x][z] > f32(y +j*32) {
            chunk_data[x][y][z] = blocktype.default // grass
        } else { continue }
        if surf2d[x][z] > f32(y +j*32)+1 {
            chunk_data[x][y][z] = blocktype.default // dirt
        }
    }}}

    chunk_verts, chunk_vao, chunk_ssbo := mesh_chunk(chunk_data)

    if chunk_verts == nil { return chunk { empty = true } }

    return chunk {
        mesh  = chunk_verts,
        data  = chunk_data,
        vao   = chunk_vao,
        ssbo  = chunk_ssbo,
        empty = false
    }
}
