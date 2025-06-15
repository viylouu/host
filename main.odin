package main

import "eng"
import "eng/shaders"
import "eng/textures"
import "eng/error"

import gl "vendor:OpenGL"
import fw "vendor:glfw"

prog_base:     u32
prog_final:    u32
vao, ssbo:     u32
//vao_fb,vbo_fb: u32
//ebo_fb:        u32
tex:           u32
//fbo, fbt:      u32

/*quad := []f32 {  // also functions as uvs
    -1,-1,
    -1, 1,
     1, 1,
     1,-1,
}
quad_inds := []u32 {
    0,1,2,
    2,3,0
}*/

chunk_data: [dynamic]i32

main :: proc() {
    eng.init(800,600,"høst")
    defer eng.end()

    eng.vsync(true)

    prog_base = shaders.load_program("data/shaders/base.vert", "data/shaders/base.frag")
    prog_final = shaders.load_program("data/shaders/final.vert", "data/shaders/final.frag")

    gl.GenVertexArrays(1, &vao)
    gl.BindVertexArray(vao)

    gl.CreateBuffers(1, &ssbo)

    add_block(&chunk_data, 0,0,0)

    gl.NamedBufferStorage(ssbo, size_of(i32) * len(chunk_data), &chunk_data[0], 0)

    tex = textures.load_texture("data/sprites/atlas.png")

    /*gl.GenFramebuffers(1, &fbo)
    gl.BindFramebuffer(gl.FRAMEBUFFER, fbo)

    /* make frame buffer texture */
        gl.GenTextures(1, &fbt)
        gl.BindTexture(gl.TEXTURE_2D, fbt)

        gl.TexImage2D(gl.TEXTURE_2D, 0, gl.RGB, 640,360, 0, gl.RGB, gl.UNSIGNED_BYTE, nil)

        gl.TexParameteri(gl.TEXTURE_2D, gl.TEXTURE_MIN_FILTER, gl.NEAREST)
        gl.TexParameteri(gl.TEXTURE_2D, gl.TEXTURE_MAG_FILTER, gl.NEAREST)

    gl.FramebufferTexture2D(gl.FRAMEBUFFER, gl.COLOR_ATTACHMENT0, gl.TEXTURE_2D, fbt, 0)

    error.critical("failed to create framebuffer!", gl.CheckFramebufferStatus(gl.FRAMEBUFFER) != gl.FRAMEBUFFER_COMPLETE)

    gl.BindFramebuffer(gl.FRAMEBUFFER, 0)

    /* make frame buffer vao vbo ebo */
        gl.GenVertexArrays(1, &vao_fb)
        gl.BindVertexArray(vao_fb)

        gl.GenBuffers(1, &vbo_fb)
        gl.BindBuffer(gl.ARRAY_BUFFER, vbo_fb)
        gl.BufferData(gl.ARRAY_BUFFER, size_of(quad), &quad, gl.STATIC_DRAW)

        gl.EnableVertexAttribArray(0)
        gl.VertexAttribPointer(0,2, gl.FLOAT, gl.FALSE, 2 * size_of(f32), cast(uintptr)0)

        gl.GenBuffers(1, &ebo_fb)
        gl.BindBuffer(gl.ELEMENT_ARRAY_BUFFER, ebo_fb)
        gl.BufferData(gl.ELEMENT_ARRAY_BUFFER, size_of(quad_inds), &quad_inds, gl.STATIC_DRAW)*/

    eng.loop(
        proc() /* update */ {
            if bool(fw.GetKey(eng.__handle, fw.KEY_ESCAPE)) { fw.SetWindowShouldClose(eng.__handle, fw.TRUE) }
        }, proc() /* render */ { 
            //gl.BindFramebuffer(gl.FRAMEBUFFER, fbo)

                //gl.Viewport(0,0,640,360)

                gl.ClearColor(106 /256.,176 /256.,173 /256., 1)
                gl.Clear(gl.COLOR_BUFFER_BIT)

                gl.UseProgram(prog_base)
                gl.BindVertexArray(vao)
                gl.BindTexture(gl.TEXTURE_2D, tex)
                gl.DrawArrays(gl.TRIANGLES, 0, cast(i32)len(chunk_data) * 6)

            /*gl.BindFramebuffer(gl.FRAMEBUFFER, 0)

            gl.Viewport(0,0, eng.__width,eng.__height)

            gl.ClearColor(0,0,0,1)
            gl.Clear(gl.COLOR_BUFFER_BIT)

            gl.UseProgram(prog_final)
            gl.BindVertexArray(vao_fb)
            gl.BindTexture(gl.TEXTURE_2D, fbt)
            gl.DrawElements(gl.TRIANGLES, 6, gl.UNSIGNED_INT, nil)*/
        }
    )
}

add_block :: proc(_chunk_data: ^[dynamic]i32, x,y,z: i32) {
    vtx: i32 = (x | y << 5 | z << 10)
    append(_chunk_data, vtx)
}
