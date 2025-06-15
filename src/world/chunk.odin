package world

chunk :: struct {
    mesh: [dynamic]i32,
    data: [32][32][32]blocktype,
    vao:  u32,
    ssbo: u32
}
