package world

blocktype :: enum u8 {
    default = 0 + (0 <<4),
    grass   = 0 + (1 <<4),
    dirt    = 1 + (1 <<4),
    stone   = 0 + (2 <<4),
    log     = 2 + (1 <<4),
    leaves  = 3 + (1 <<4),

    air     = 15 + (15 <<4)
}
