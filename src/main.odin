package main

import "world"

import "../eng"
import "../eng/shaders"
import "../eng/textures"
import "../eng/error"
import "../eng/time"

import noise "../lib/fastnoiselite"

import gl "vendor:OpenGL"
import fw "vendor:glfw"
import stbi "vendor:stb/image"

prog_base:     u32
prog_final:    u32
tex:           u32

verts_lc:      i32
chpos_lc:      i32

chunk: world.chunk

main :: proc() {
    eng.init(800,600,"høst"); defer eng.end()
    world.init(0)

    eng.vsync(true)

    prog_base = shaders.load_program("data/shaders/base.vert", "data/shaders/base.frag"); defer gl.DeleteProgram(prog_base)
    prog_final = shaders.load_program("data/shaders/final.vert", "data/shaders/final.frag"); defer gl.DeleteProgram(prog_final)

    chunk = world.gen_chunk(); defer world.delete_chunk(&chunk)

    stbi.set_flip_vertically_on_load(0)
    tex = textures.load_texture("data/sprites/atlas.png"); defer gl.DeleteTextures(1, &tex)

    verts_lc = gl.GetUniformLocation(prog_base, "vertices")
    chpos_lc = gl.GetUniformLocation(prog_base, "chunkPos")

    gl.Enable(gl.DEPTH_TEST)

    eng.loop(
        proc() /* update */ {
            if bool(fw.GetKey(eng.__handle, fw.KEY_ESCAPE)) { fw.SetWindowShouldClose(eng.__handle, fw.TRUE) }
        }, proc() /* render */ { 
            gl.ClearColor(106 /256.,176 /256.,173 /256., 1)
            gl.Clear(gl.COLOR_BUFFER_BIT | gl.DEPTH_BUFFER_BIT)

            gl.Uniform1i(verts_lc, cast(i32)len(chunk.mesh))
            gl.Uniform3f(chpos_lc, 0,0,0)

            gl.UseProgram(prog_base)
            gl.BindBufferBase(gl.SHADER_STORAGE_BUFFER, 0, chunk.ssbo)
            gl.BindVertexArray(chunk.vao)
            gl.BindTexture(gl.TEXTURE_2D, tex)
            gl.DrawArrays(gl.TRIANGLES, 0, cast(i32)len(chunk.mesh) * 6)
        }
    )
}
