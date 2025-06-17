package world

chunk :: struct {
    mesh: [dynamic]vertex,
    data: [32][32][32]blocktype,
    vao:  u32,
    ssbo: u32,

    empty: bool
}

delete_these_chunks_pwease :: proc(chunks: [dynamic]^chunk) {
    for item in chunks { delete_chunk(item) }
}
