Prevent building placement on occupied tiles (buildings + decor)
Context
Currently world.place_building() instantiates a building wherever the player clicks — nothing stops stacking buildings on top of each other or on decor tiles. The goal is tile-based occupancy checking: a placement is invalid if any cell of the building's footprint (from BuildingData.width/height) is already taken by a placed building or by a decor tile on ObstaclesTileMap. While hovering an invalid spot, the cursor shows its blocked visual (red) instead of the blue build ghost, and LMB does nothing.

Approach (per the user's suggestion): building footprints are recorded on a new invisible OccupancyTileMap TileMapLayer; decor is queried directly from the existing ObstaclesTileMap (it's already a tile layer — no duplication needed). A terrain check is included too: cells with no terrain tile (off-map) also block placement.

Geometry: footprint → cells
The grid is stacked isometric (tile_shape=1, 32×16), where integer neighbor math is parity-dependent and error-prone. Instead, sample pixel-space cell centers and let local_to_map() convert:

snap_to_cell() returns the top vertex V of the hovered diamond (avg of cell center and the center 2 rows up).
Sub-cell centers: center(i,j) = V + (0,8) + i·(-16,8) + j·(16,8) for i in range(w) (down-left axis), j in range(h) (down-right axis). This matches the region the scaled $build diamond displays.
rotated (flip_h) = swap w/h in the loop (a no-op for the current 3×3 buildings; document the convention in a comment).
Same Vector2i cells are valid across all three layers (identical tile shape/size/layout, no node transforms).
Changes
1. world.tscn — add the occupancy layer (hand-edit as text)
Insert after the ObstaclesTileMap block (after its tile_set = SubResource("TileSet_0yij4") line, ~line 87):

[node name="OccupancyTileMap" type="TileMapLayer" parent="."]
tile_set = ExtResource("4_gb53w")
Reuses terrain.tres (already declared as ExtResource("4_gb53w") in this file). Marker tile: source 0, atlas (0, 0) — verified to exist.
No unique_id (editor assigns one on next save); no visible = false in the scene — hide it in world._ready() instead, so the layer stays visible/paintable in the editor for debugging but never shows in-game.
2. world.gd — footprint helpers, can_place, seeding
Add @onready typed refs: terrain ($TerrainTileMap), obstacles ($ObstaclesTileMap), occupancy ($OccupancyTileMap); constants OCCUPIED_SOURCE_ID = 0, OCCUPIED_ATLAS_COORDS = Vector2i(0, 0).
_ready(): occupancy.visible = false, then seed — for each Building child of $Buildings, _mark_footprint(building.data, building.rotated, building.position) (their position is already the anchor top-vertex).
get_footprint_cells(data: BuildingData, rotated: bool, anchor: Vector2) -> Array[Vector2i]: the geometry above, deriving (16, 8) from terrain.tile_set.tile_size / 2.
can_place(blueprint: BuildingBlueprint, mouse_position: Vector2) -> bool: anchor = snap_to_cell(mouse_position); false if any footprint cell has occupancy.get_cell_source_id(cell) != -1 (building), obstacles.get_cell_source_id(cell) != -1 (decor), or terrain.get_cell_source_id(cell) == -1 (off-map).
_mark_footprint(data, rotated, anchor): occupancy.set_cell(cell, OCCUPIED_SOURCE_ID, OCCUPIED_ATLAS_COORDS) per footprint cell.
place_building(): early-return if not can_place(...) (defense in depth); after add_child, call _mark_footprint(...).
Cleanup while here: remove dead BUILDING_CELL_WIDTH/HEIGHT vars and the leftover print(); add return types to touched functions (snap_to_cell(position: Vector2) -> Vector2).
3. cursor.tscn — fix the blocked polygon
Line 21: change to polygon = PackedVector2Array(0, 0, -16, 8, 0, 16, 16, 8) so it matches the select/build diamond (currently it's offset/mis-oriented).

4. cursor.gd — blocked-build mode
Add set_to_blocked_mode(building_blueprint: BuildingBlueprint) → set_mode(CursorMode.BLOCKED, building_blueprint) (matches the existing set_to_*_mode convention; CursorMode.BLOCKED already exists but was never entered).
update(): also set $blocked.scale = building_size (alongside $build.scale).
set_mode() BLOCKED branch: show $blocked, call update(building_blueprint), show $sprite2d tinted red (GHOST_MODULATE_BLOCKED = Color(1, 0.25, 0.25, 0.45)); PLACE_BUILDING branch must restore the blue tint (GHOST_MODULATE_BUILD = the current scene modulate Color(0.25, 0.325, 1, 0.455)), since the Sprite2D is shared.
5. game.gd — wiring + refresh after placement
Extract _update_cursor(): snap cursor position, then set_to_select_mode() if nothing selected, else set_to_building_mode(...) if $world.can_place(...) else set_to_blocked_mode(...).
Mouse-motion branch of _input → just _update_cursor().
LMB: guard placement with can_place, then call _update_cursor() after placing — this flips the cursor to blocked instantly (no mouse-motion event fires after a click, and the cursor now hovers the just-placed building).
R (rotate) and RMB (cancel): call _update_cursor() so the cursor state refreshes immediately.
Order
world.tscn → world.gd → cursor.tscn → cursor.gd → game.gd. (The layer must exist before world.gd references $OccupancyTileMap.)

Verification (manual — Claude can't run Godot; user tests in the editor)
Open world.tscn: OccupancyTileMap present, no parse errors, scene renders unchanged.
Run; pick a building; hover empty grass → blue diamond + blue ghost.
Hover the pre-placed house and shipwreck → red diamond + red ghost, including when the 3×3 footprint only partially overlaps (approach from all 4 diagonals).
Hover decor tiles on ObstaclesTileMap → red.
Hover the map edge (footprint partly off painted terrain) → red.
LMB on red → nothing placed. LMB on blue → placed, and cursor turns red immediately without moving the mouse.
Two adjacent non-overlapping placements both succeed; hovering either afterwards → red.
R rotates and revalidates; RMB reverts to the select cursor instantly.
Debug: paint a tile on OccupancyTileMap in the editor → that cell blocks in-game but the marker is invisible.
Notes / known limits
Width→down-left axis convention is unverifiable while all buildings are square; if wrong, it's a one-line swap when the first non-square building appears (comment it).
The scaled-diamond ghost ($build/$blocked scaled by (w,h)) is only shape-correct for square footprints — existing limitation, unchanged.
No removal feature exists yet; when added, it must clear footprint cells (hence get_footprint_cells/_mark_footprint as reusable helpers).
Decor blocking follows exactly what's painted on ObstaclesTileMap; sprites overhanging unpainted cells don't block those cells.
