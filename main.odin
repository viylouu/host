package main

import "eng"
import "eng/shaders"

import gl "vendor:OpenGL"

prog_base: u32
vao, ssbo: u32

chunk_data: [dynamic]i32

main :: proc() {
    eng.init(800,600,"høst")
    defer eng.end()

    eng.vsync(true)

    prog_base = shaders.load_program("data/shaders/base.vert", "data/shaders/base.frag")

    gl.GenVertexArrays(1, &vao)
    gl.BindVertexArray(vao)

    gl.CreateBuffers(1, &ssbo)

    add_block(&chunk_data, 0,0,0)

    gl.NamedBufferStorage(ssbo, size_of(i32) * len(chunk_data), &chunk_data[0], 0)

    eng.loop(
        proc() /* update */ {

        }, proc() /* render */ { 
            gl.ClearColor(106 /256.,176 /256.,173 /256., 1)
            gl.Clear(gl.COLOR_BUFFER_BIT)

            gl.UseProgram(prog_base)
            gl.BindVertexArray(vao)
            gl.DrawArrays(gl.TRIANGLES, 0, cast(i32)len(chunk_data) * 6)
        }
    )
}

add_block :: proc(_chunk_data: ^[dynamic]i32, x,y,z: i32) {
    vtx: i32 = (x | y << 5 | z << 10)
    append(_chunk_data, vtx)
}
