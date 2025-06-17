package world

import gl "vendor:OpenGL"

@private
mesh_chunk :: proc(data: [32][32][32]blocktype) -> ([dynamic]vertex, u32,u32) {
    // super duper ultro complex meshing
    chunk_verts: [dynamic]vertex
    for y in 0..<32 { for x in 0..<32 { for z in 0..<32 { 
        if data[x][y][z] == blocktype.air { continue }

        if x != 31 && data[x+1][y][z] != blocktype.air &&
           y != 31 && data[x][y+1][z] != blocktype.air &&
           z != 31 && data[x][y][z+1] != blocktype.air { continue }

        add_block(&chunk_verts, i32(x),i32(y),i32(z), data[x][y][z])
    }}}

    if len(chunk_verts) == 0 { return nil, 0,0 }

    vao, ssbo: u32
    gl.GenVertexArrays(1, &vao)
    gl.BindVertexArray(vao)

    gl.CreateBuffers(1, &ssbo)
    gl.NamedBufferStorage(ssbo, size_of(vertex) * len(chunk_verts), &chunk_verts[0], 0)

    return chunk_verts, vao,ssbo
}

@private
add_block :: proc(chunk_verts: ^[dynamic]vertex, x,y,z: i32, type: blocktype) {
    low := (x | y << 5 | z << 10 | i32(type) << 15)
    high: i32 = 0
    append(chunk_verts, vertex{low,high})
}

delete_chunk :: proc(chk: ^chunk) {
    chk := chk
    gl.DeleteBuffers(1, &chk.ssbo)
    gl.DeleteVertexArrays(1, &chk.vao)
    delete(chk.mesh)
    free(&chk.data)
    chk = nil
}
