# CLAUDE.md

## Project overview

An isometric city-builder / colony-sim prototype set on an alien planet. The player places buildings (habitats, substations, chemical reactors…) on an isometric tile grid around a crashed spaceship.

- **Engine**: Godot 4.7, GL Compatibility renderer.
- **Language**: pure GDScript. The editor used is the mono build, but there is no C# in the project (no `.cs`/`.csproj`) — do not introduce C#.
- **Art style**: pixel art (`default_texture_filter = nearest`), isometric diamond tiles of 32×16 px (32×32 source regions, `texture_origin=(0,8)`).
- **Main scene**: `scenes/game.tscn` (set in `project.godot`).

Planned systems (see `ideas.md` for details): map overlays (humidity, temperature, electrical power), an electricity chain (shipwreck as power source → cables → substation → nearby buildings), decorative "clutter" props around buildings that reflect their stats (with walls blocking clutter propagation), and building resources (stone, bio-polymer).

## Running & testing

The user runs the Godot editor manually on Windows (this repo is edited from WSL; the editor binary lives outside the repo). **Claude cannot launch the game or run headless script checks** — after making changes, ask the user to run/test them in the editor.

`.godot/` is engine-generated and gitignored; never edit or rely on its contents.

## Code structure

```
scenes/                     # scenes with their scripts side by side
  game.tscn / game.gd       # main scene: top-level input controller + UI CanvasLayer
  menu_button.gd            # building-picker MenuButton (attached inside game.tscn)
  cursor.tscn / cursor.gd   # cursor state machine (CursorMode: SELECT / PLACE_BUILDING / BLOCKED)
  world/
    world.tscn / world.gd   # TileMapLayers (terrain + obstacles), camera, Buildings container
    MoveableCamera.gd       # Camera2D right-drag panning
  building/
    building.tscn / Building.gd  # placed building node (@tool for live editor preview)
    BuildingData.gd         # Resource: name, texture, width, height
    BuildingBlueprint.gd    # transient placement state (data + rotated), never saved to disk
resources/                  # authored .tres resources
  buildingdata/             # one BuildingData .tres per building type
  tilesets/terrain.tres     # tileset used by the terrain TileMapLayer
assets/                     # raw art & audio, grouped by type
  buildings/  terrain/  ui/  music/
ideas.md                    # design notes / roadmap
```

Scene instancing chain: `game.tscn` → `world.tscn` → { `building.tscn` (2 pre-placed + runtime instances), `cursor.tscn` }.

Notes on `assets/`: the tileset references only `terrain/spritesheet.png`; the individual `terrain/tile_NNN.png` files are unreferenced raw asset-pack exports. `music/` is currently unused (no AudioStreamPlayer anywhere).

## Architecture

- **Data-driven buildings**: a building type is just a `BuildingData` `.tres` in `resources/buildingdata/` (name, texture, footprint width/height). Adding a building type requires no code — create the `.tres` and add it to `BuildingsButton`'s exported `building_list`.
- **Placement flow**: `BuildingsButton` popup → `building_selected` signal (`menu_button.gd`) → `game.gd` stores a `BuildingBlueprint` → cursor shows a ghost preview (`cursor.gd`) → LMB calls `world.place_building()`, which instantiates `building.tscn` under `world/Buildings`. RMB cancels the selection; R (`rotate_building` action) toggles rotation.
- **Isometric snapping**: `world.gd::snap_to_cell()` averages `map_to_local(map_pos)` with `map_to_local(map_pos - Vector2i(0, 2))` to snap to diamond cells.
- **Global classes** (registered via `class_name`): `Building`, `BuildingData`, `BuildingBlueprint`, `Cursor`.
- **No autoloads/singletons, no addons/plugins, no node groups.** The only custom signal is `building_selected`; the only custom input action is `rotate_building` (R). Mouse buttons are currently checked directly (`MOUSE_BUTTON_LEFT`/`RIGHT`) — prefer defining named input actions for new inputs.

## Conventions

Target the **official Godot style guide** for all new code:

- Files & directories: `snake_case` (`.gd`, `.tscn`, `.tres`, folders).
- Node names and `class_name`: `PascalCase`. Functions, variables, signals: `snake_case`. Constants: `const SCREAMING_SNAKE_CASE`.
- Indentation: tabs. Prefer static typing (`var x: int`, typed function signatures).
- Commits: Conventional Commits (`feat: …`, `fix: …`).

Legacy inconsistencies exist (PascalCase script filenames like `Building.gd`, lowercase node names like `world`/`cursor`/`camera`, `dragSensitivity` in `MoveableCamera.gd`). New code follows the official style; only rename existing things deliberately — see the node-path gotcha below.

## Gotchas

- **Hardcoded node paths**: `game.gd`, `cursor.gd`, and `world.gd` address nodes by literal paths (`$world`, `$world.get_node("cursor")`, `$sprite2d`, `$Buildings`, `$select`/`$build`/`$blocked`). Renaming a node silently breaks the scripts — update all references together.
- **Sidecar files**: `.gd.uid` and `.import` files must be committed and moved/renamed together with their script/asset.
- **`Building.gd` is `@tool`**: it runs inside the editor. Its `data` export has a setter that refreshes the preview, but `rotated` does not — editing `rotated` in the inspector won't update the preview.
- **Dead code** (present, safe to clean up when touching the file): unused `BUILDING_CELL_WIDTH/HEIGHT` vars and a leftover `print()` in `world.gd`; an empty embedded script stub on `TerrainTileMap` inside `world.tscn`; the `BLOCKED` cursor mode is defined but never entered; empty `_process()` boilerplate in `menu_button.gd`.
- **`menu_button.gd` bug-prone connect**: `get_popup().id_pressed.connect(...)` is called inside the for loop over `building_list`, so it connects once per building.
- **Misspelled asset**: `assets/buildings/chemical_plan.png` (missing "t"); renaming it requires updating `resources/buildingdata/chemical_plant.tres` and the `.import` sidecar.
- **Display names ≠ filenames** in `resources/buildingdata/` (e.g. `house.tres` is named "Habitat", `chemical_plant.tres` is "Chemical Reactor").
