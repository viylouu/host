package player

import "../world"

import "../../eng"
import "../../eng/time"

import "core:math"

import noise "../../lib/fastnoiselite"

import fw "vendor:glfw"

vec3 :: [3]f32

pos: vec3

init :: proc() {
    pos = vec3{16,20,16}
}

move :: proc() {
    pos.y = math.floor(noise.get_noise_2d(world.__surfnoise, math.round(pos.x), math.round(pos.z)) * 4 + 16) + 1;

    if fw.GetKey(eng.__handle, fw.KEY_W) == fw.PRESS {
        pos.x -= f32(time.delta) * 4
        pos.z -= f32(time.delta) * 4
    }

    if fw.GetKey(eng.__handle, fw.KEY_S) == fw.PRESS {
        pos.x += f32(time.delta) * 4
        pos.z += f32(time.delta) * 4
    }

    if fw.GetKey(eng.__handle, fw.KEY_A) == fw.PRESS {
        pos.x += f32(time.delta) * 4
        pos.z -= f32(time.delta) * 4
    }

    if fw.GetKey(eng.__handle, fw.KEY_D) == fw.PRESS {
        pos.x -= f32(time.delta) * 4
        pos.z += f32(time.delta) * 4
    }
}
