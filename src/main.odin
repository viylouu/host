package main

import "core:fmt"
import sl "core:math/linalg/glsl"

import "world"
import "player"

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
prog_player:   u32
//prog_final:    u32

atlas:         u32; atlas_lc:     i32
atlas_n:       u32; atlas_n_lc:   i32
atlas_h:       u32; atlas_h_lc:   i32
atlas_lut:     u32; atlas_lut_lc: i32
palette:       u32; palette_lc:   i32
inventory:     u32

verts_lc:      i32
chpos_lc:      i32
proj_lc:       i32

proj_p_lc:     i32
pos_p_lc:      i32

proj_mat:      sl.mat4

scene: map[vec3]world.chunk
chunks: [dynamic]^world.chunk

main :: proc() {
    eng.init(1280,720,"høst"); defer eng.end()
    world.init(0)
    player.init()

    eng.vsync(true)

    prog_base   = shaders.load_program("data/shaders/base.vert", "data/shaders/base.frag"); defer gl.DeleteProgram(prog_base)
    prog_player = shaders.load_program("data/shaders/player.vert", "data/shaders/player.frag"); defer gl.DeleteProgram(prog_player)
    //prog_final = shaders.load_program("data/shaders/final.vert", "data/shaders/final.frag"); defer gl.DeleteProgram(prog_final)

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
    atlas = textures.load_texture("data/sprites/atlas.png", gl.TEXTURE0); defer gl.DeleteTextures(1, &atlas)
    atlas_n = textures.load_texture("data/sprites/atlas-n.png", gl.TEXTURE1); defer gl.DeleteTextures(1, &atlas_n)
    atlas_h = textures.load_texture("data/sprites/atlas-h.png", gl.TEXTURE2); defer gl.DeleteTextures(1, &atlas_h)
    atlas_lut = textures.load_texture("data/sprites/atlas-lut.png", gl.TEXTURE3); defer gl.DeleteTextures(1, &atlas_lut)
    palette = textures.load_texture("data/sprites/palette.png", gl.TEXTURE4); defer gl.DeleteTextures(1, &palette)

    atlas_lc     = gl.GetUniformLocation(prog_base, "atlas")
    atlas_n_lc   = gl.GetUniformLocation(prog_base, "atlas_n")
    atlas_h_lc   = gl.GetUniformLocation(prog_base, "atlas_h")
    atlas_lut_lc = gl.GetUniformLocation(prog_base, "atlas_lut")
    palette_lc   = gl.GetUniformLocation(prog_base, "palette")

    inventory = textures.load_texture("data/sprites/inventory.png"); defer gl.DeleteTextures(1, &inventory)

    verts_lc = gl.GetUniformLocation(prog_base, "vertices")
    chpos_lc = gl.GetUniformLocation(prog_base, "chunkPos")
    proj_lc  = gl.GetUniformLocation(prog_base, "proj")

    proj_p_lc = gl.GetUniformLocation(prog_player, "proj")
    pos_p_lc  = gl.GetUniformLocation(prog_player, "pos")

    gl.Enable(gl.DEPTH_TEST)

    proj_mat = sl.mat4Ortho3d(-1,1,-1,1,-1000000,1000000)

    eng.loop(
        proc() /* update */ {
            if bool(fw.GetKey(eng.__handle, fw.KEY_ESCAPE)) { fw.SetWindowShouldClose(eng.__handle, fw.TRUE) }

            player.move()
        }, proc() /* render */ { 
            gl.ClearColor(106 /256.,176 /256.,173 /256., 1)
            gl.Clear(gl.COLOR_BUFFER_BIT | gl.DEPTH_BUFFER_BIT)
            
            gl.UseProgram(prog_base)
            gl.ActiveTexture(gl.TEXTURE0)
            gl.BindTexture(gl.TEXTURE_2D, atlas)
            
            /* world */ {
                gl.ActiveTexture(gl.TEXTURE1)
                gl.BindTexture(gl.TEXTURE_2D, atlas_n)
                gl.ActiveTexture(gl.TEXTURE2)
                gl.BindTexture(gl.TEXTURE_2D, atlas_h)
                gl.ActiveTexture(gl.TEXTURE3)
                gl.BindTexture(gl.TEXTURE_2D, atlas_lut)
                gl.ActiveTexture(gl.TEXTURE4)
                gl.BindTexture(gl.TEXTURE_2D, palette)

                gl.Uniform1i(atlas_lc, 0)
                gl.Uniform1i(atlas_n_lc, 1)
                gl.Uniform1i(atlas_h_lc, 2)
                gl.Uniform1i(atlas_lut_lc, 3)
                gl.Uniform1i(palette_lc, 4)

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

            /* player */ {
                gl.UseProgram(prog_player)

                gl.UniformMatrix4fv(proj_p_lc, 1, gl.FALSE, transmute([^]f32)&proj_mat)
                gl.Uniform3f(pos_p_lc, player.pos.x, player.pos.y, player.pos.z)

                gl.DrawArrays(gl.TRIANGLES, 0, 6)
                // here is why we don't need a vbo or vao (vao is already exist from last draw call)
                /* 
                    Mom, can we have VBO?
                    No, we have VBO at home
                    VBO at home: gl_VertexId + const vec3 position[]
                */
            }
        }
    )
}
