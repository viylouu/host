package main

import "world"

import "../eng"
import "../eng/shaders"
import "../eng/textures"
import "../eng/error"

import noise "../lib/fastnoiselite"

import gl "vendor:OpenGL"
import fw "vendor:glfw"
import stbi "vendor:stb/image"

prog_base:     u32
prog_final:    u32
vao, ssbo:     u32
tex:           u32

vert_lc:       i32

chunk: world.chunk

main :: proc() {
    eng.init(800,600,"høst"); defer eng.end()
    world.init(0)

    eng.vsync(true)

    prog_base = shaders.load_program("data/shaders/base.vert", "data/shaders/base.frag"); defer gl.DeleteProgram(prog_base)
    prog_final = shaders.load_program("data/shaders/final.vert", "data/shaders/final.frag"); defer gl.DeleteProgram(prog_final)

    gl.GenVertexArrays(1, &vao); defer gl.DeleteVertexArrays(1, &vao)
    gl.BindVertexArray(vao)

    gl.CreateBuffers(1, &ssbo); defer gl.DeleteBuffers(1, &ssbo)

    chunk = world.gen_chunk()
    
    gl.NamedBufferStorage(ssbo, size_of(i32) * len(chunk.mesh), &chunk.mesh[0], 0)

    stbi.set_flip_vertically_on_load(0)
    tex = textures.load_texture("data/sprites/atlas.png"); defer gl.DeleteTextures(1, &tex)

    vert_lc = gl.GetUniformLocation(prog_base, "vertices")

    gl.Enable(gl.DEPTH_TEST)

    eng.loop(
        proc() /* update */ {
            if bool(fw.GetKey(eng.__handle, fw.KEY_ESCAPE)) { fw.SetWindowShouldClose(eng.__handle, fw.TRUE) }
        }, proc() /* render */ { 
            gl.ClearColor(106 /256.,176 /256.,173 /256., 1)
            gl.Clear(gl.COLOR_BUFFER_BIT | gl.DEPTH_BUFFER_BIT)

            gl.Uniform1i(vert_lc, cast(i32)len(chunk.mesh))

            gl.UseProgram(prog_base)
            gl.BindBufferBase(gl.SHADER_STORAGE_BUFFER, 0, ssbo)
            gl.BindVertexArray(vao)
            gl.BindTexture(gl.TEXTURE_2D, tex)
            gl.DrawArrays(gl.TRIANGLES, 0, cast(i32)len(chunk.mesh) * 6)
        }
    )
}
