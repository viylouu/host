package main

import "eng"
import "eng/shaders"

import gl "vendor:OpenGL"
import stbi "vendor:stb/image"

prog_base: u32
vao, ssbo: u32
tex:       u32

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

    stbi.set_flip_vertically_on_load(1)

    wh,channels := i32(256), i32(4)
    tex_data := stbi.load("data/sprites/atlas.png", &wh,&wh, &channels, 4)
    
    gl.GenTextures(1, &tex)
    gl.ActiveTexture(gl.TEXTURE0)
    gl.BindTexture(gl.TEXTURE_2D, tex)

    gl.TexParameteri(gl.TEXTURE_2D, gl.TEXTURE_MIN_FILTER, gl.NEAREST);
    gl.TexParameteri(gl.TEXTURE_2D, gl.TEXTURE_MAG_FILTER, gl.NEAREST);
    gl.TexParameteri(gl.TEXTURE_2D, gl.TEXTURE_WRAP_S, gl.REPEAT);
    gl.TexParameteri(gl.TEXTURE_2D, gl.TEXTURE_WRAP_T, gl.REPEAT);

    gl.TexImage2D(gl.TEXTURE_2D, 0, gl.RGBA, wh,wh, 0, gl.RGBA, gl.UNSIGNED_BYTE, &tex_data[0])

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
