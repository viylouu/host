package main

import "eng"

import gl "vendor:OpenGL"

main :: proc() {
    eng.init(800,600,"høst")
    defer eng.end()

    eng.vsync(true)

    eng.loop(
        proc() /* update */ {

        }, proc() /* render */ { 
            gl.ClearColor(106 /256.,176 /256.,173 /256., 1)
            gl.Clear(gl.COLOR_BUFFER_BIT)
        }
    )
}
