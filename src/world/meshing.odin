package world

@private
mesh_chunk :: proc(data: [32][32][32]blocktype) -> [dynamic]i32 {
    // super duper ultro complex meshing
    chunk_verts: [dynamic]i32
    for y in 0..<32 { for x in 0..<32 { for z in 0..<32 { 
        if data[x][y][z] != blocktype.air {
            add_block(&chunk_verts, i32(x),i32(y),i32(z), data[x][y][z])
        }
    }}}
    return chunk_verts
}

@private
add_block :: proc(chunk_verts: ^[dynamic]i32, x,y,z: i32, type: blocktype) {
    vtx: i32 = (x | y << 5 | z << 10 | i32(type) << 15)
    append(chunk_verts, vtx)
}
