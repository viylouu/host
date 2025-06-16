package main

import "core:fmt"
import sl "core:math/linalg/glsl"

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

vec3 :: [3]int

prog_base:     u32
prog_final:    u32
tex:           u32

verts_lc:      i32
chpos_lc:      i32
proj_lc:       i32

proj_mat:      sl.mat4

scene: map[vec3]world.chunk
chunks: [dynamic]^world.chunk

main :: proc() {
    eng.init(1280,720,"høst"); defer eng.end()
    world.init(0)

    eng.vsync(true)

    prog_base = shaders.load_program("data/shaders/base.vert", "data/shaders/base.frag"); defer gl.DeleteProgram(prog_base)
    prog_final = shaders.load_program("data/shaders/final.vert", "data/shaders/final.frag"); defer gl.DeleteProgram(prog_final)

    scene = make(map[vec3]world.chunk); defer delete(scene)

    chunks = make([dynamic]^world.chunk)
    defer world.delete_these_chunks_pwease(chunks)
    defer delete(chunks)
    
    for x in -4..=4 { for y in -4..=4 { for z in -4..=4 {
        chunk := world.gen_chunk(x,y,z); 
        if chunk.empty { continue }
        append(&chunks, &chunk)
        scene[vec3{x,y,z}] = chunk
    }}}
    
    stbi.set_flip_vertically_on_load(0)
    tex = textures.load_texture("data/sprites/atlas.png"); defer gl.DeleteTextures(1, &tex)

    verts_lc = gl.GetUniformLocation(prog_base, "vertices")
    chpos_lc = gl.GetUniformLocation(prog_base, "chunkPos")
    proj_lc  = gl.GetUniformLocation(prog_base, "proj")

    gl.Enable(gl.DEPTH_TEST)

    proj_mat = sl.mat4Ortho3d(-1,1,-1,1,-1000000,1000000)

    eng.loop(
        proc() /* update */ {
            if bool(fw.GetKey(eng.__handle, fw.KEY_ESCAPE)) { fw.SetWindowShouldClose(eng.__handle, fw.TRUE) }
        }, proc() /* render */ { 
            gl.ClearColor(106 /256.,176 /256.,173 /256., 1)
            gl.Clear(gl.COLOR_BUFFER_BIT | gl.DEPTH_BUFFER_BIT)
            
            gl.UseProgram(prog_base)
            gl.BindTexture(gl.TEXTURE_2D, tex)
            gl.UniformMatrix4fv(proj_lc, 1, gl.FALSE, transmute([^]f32)&proj_mat)

            for x in -4..=4 { for y in -4..=4 { for z in -4..=4 { 
                chunk, exists := scene[vec3{x,y,z}]
                if !exists { continue }

                gl.Uniform3f(chpos_lc, f32(x),f32(y),f32(z))
                gl.BindBufferBase(gl.SHADER_STORAGE_BUFFER, 0, chunk.ssbo)
                gl.BindVertexArray(chunk.vao)
                gl.DrawArrays(gl.TRIANGLES, 0, cast(i32)len(chunk.mesh) * 6)
            }}}      
        }
    )
}
