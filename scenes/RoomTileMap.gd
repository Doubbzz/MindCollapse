extends TileMap

const TILE_SIZE := Vector2i(32, 32)
const MAP_WIDTH := 40
const MAP_HEIGHT := 22

func _ready() -> void:
    if tile_set != null:
        return
    var image := Image.create(TILE_SIZE.x, TILE_SIZE.y, false, Image.FORMAT_RGBA8)
    image.fill(Color(0.12, 0.1, 0.16, 1.0))
    var texture := ImageTexture.create_from_image(image)
    var atlas_source := TileSetAtlasSource.new()
    atlas_source.texture = texture
    atlas_source.texture_region_size = TILE_SIZE
    atlas_source.texture_region_margin = Vector2i.ZERO
    atlas_source.use_texture_padding = false
    atlas_source.create_tile(Vector2i.ZERO)
    atlas_source.set_tile_texture_region(Vector2i.ZERO, Rect2i(Vector2i.ZERO, TILE_SIZE))

    var room_tile_set := TileSet.new()
    room_tile_set.add_source(0, atlas_source)
    tile_set = room_tile_set
    clear()

    for x in range(MAP_WIDTH):
        for y in range(MAP_HEIGHT):
            set_cell(0, Vector2i(x, y), 0, Vector2i.ZERO)
