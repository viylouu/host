package player

import "../world"

import "../../eng"
import "../../eng/time"

import "core:math"

import noise "../../lib/fastnoiselite"

import fw "vendor:glfw"

vec3 :: [3]f32

pos: vec3
_lpos: vec3
_pos: vec3

move_cool: f32 = 0.25
mv_c: f32 = 0
anim_cool: f32 = move_cool
an_c: f32 = 0
reset: bool
wait_reset: bool

init :: proc() {
    pos = vec3{16,20,16}
    _pos = pos
}

easeOut :: proc(x: f32) -> f32 {
    return x == 1 ? 1 : 1 - math.pow(2, -10 * x);
}

easeOutBack :: proc(x: f32) -> f32 {
    c1 :: 1.70158
    c3 :: c1 + 1

    return 1 + c3 * math.pow(x - 1, 3) + c1 * math.pow(x - 1, 2)
}

easeInBack :: proc(x: f32) -> f32 {
    c1 :: 1.70158
    c3 :: c1 + 1

    return c3 * x * x * x - c1 * x * x
}

move :: proc() {
    _pos.y = math.floor(noise.get_noise_2d(world.__surfnoise, _pos.x, _pos.z) * 4 + 16) + 1;

    mv_c += f32(time.delta)
    an_c += f32(time.delta)

    if an_c >= anim_cool {
        _lpos = _pos
        an_c = 0
    }

    if reset { an_c = 0; reset = false; _lpos = pos }

    if mv_c >= move_cool {
        if fw.GetKey(eng.__handle, fw.KEY_W) == fw.PRESS {
            _pos.z -= 1
            mv_c = 0
            if wait_reset { reset = true; wait_reset = false }
        }

        if fw.GetKey(eng.__handle, fw.KEY_A) == fw.PRESS {
            _pos.x += 1
            mv_c = 0
            if wait_reset { reset = true; wait_reset = false }
        }

        if fw.GetKey(eng.__handle, fw.KEY_S) == fw.PRESS {
            _pos.z += 1
            mv_c = 0
            if wait_reset { reset = true; wait_reset = false }
        }

        if fw.GetKey(eng.__handle, fw.KEY_D) == fw.PRESS {
            _pos.x -= 1
            mv_c = 0
            if wait_reset { reset = true; wait_reset = false }
        }
    }

    if fw.GetKey(eng.__handle, fw.KEY_W) != fw.PRESS &&
       fw.GetKey(eng.__handle, fw.KEY_A) != fw.PRESS &&
       fw.GetKey(eng.__handle, fw.KEY_S) != fw.PRESS &&
       fw.GetKey(eng.__handle, fw.KEY_D) != fw.PRESS {
        mv_c = move_cool
        wait_reset = true
    }

    pos.x = math.lerp(_lpos.x, _pos.x, easeOut(an_c))
    pos.z = math.lerp(_lpos.z, _pos.z, easeOut(an_c))
    //pos.y = math.lerp(_lpos.y, _pos.y, easeOut(an_c))
    if _lpos.y < _pos.y {
        pos.y = math.lerp(_lpos.y, _pos.y, easeOutBack(an_c))
    } else {
        pos.y = math.lerp(_lpos.y, _pos.y, easeInBack(an_c))
    }
    
}
