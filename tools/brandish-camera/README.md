# Brandish camera and directional assets

The perspective is experimental and **off when a round starts**. An admin
(`R_ADMIN`) or coder (`R_DEBUG`) runs **Debug > Toggle Brandish Perspective**
to switch every eligible player at once; running it again restores the normal
view. **Debug > Set Default Client Direction** sets the round's baseline heading
for current and future clients. Pass `NORTH`/`SOUTH`/`EAST`/`WEST` (or
`1`/`2`/`4`/`8`) on the command line, or run it without arguments to choose.
Active Brandish cameras and Observe mirrors retain their heading, then return
to the latest baseline when released. Ordinary movement already follows the
screen direction at every baseline heading.
Logical view sizes stay screen-relative: a requested `17x15` is applied to
BYOND as `15x17` at EAST/WEST so the displayed viewport stays `17x15`.
HUD layout and mouse projection use screen dimensions; visibility uses the
applied world rectangle. Preferences and zoom requests retain their logical axes.
The toggle verb flips the `brandish_camera` config flag at runtime. The flag is
not read from the config files for now, so there is no `BRANDISH_CAMERA` line
in `config/game_options.txt`.

While enabled, the forward-facing camera applies to living players, including
soft critical health. `/mob/proc/brandish_perspective_allowed()` decides
eligibility and excludes:

- Lobby players, dead bodies and ghosts (any non-living mob).
- Silicons: cyborgs, AIs and pAIs.
- Brains (MMI, positronic brain) and shades (soulstones, sentient artifacts).
- Any living mob whose `loc` is an item, i.e. a mind housed inside a carried
  object such as a possessed blade.

Lockers, cryo cells, vehicles and mechs are not items and keep the camera.
Unconsciousness and hard critical health pause input while retaining the same
view direction and offset. Remote control releases the camera; returning to
direct control creates it again. A native eye on the body's containing locker,
cryo cell, carrier or vehicle remains a local view and preserves the camera.

Administrators and coders can opt their current body out through **Debug > Brandish
Camera** while the perspective is enabled. Generated artwork stays bound whether
the flag is on or off: it is pixel-identical at the default heading, so the
switch needs no world rebuild.

The camera looks three tiles ahead, keeps the character below center, and turns
in 90-degree steps. Two tiles use screen-relative offsets; the remaining tile
uses world offsets projected for the current heading. This keeps the total
screen displacement constant while making the outer tile row available in
rotated views. Shake and dizziness own separate effects and cannot restore an
obsolete camera position. Clicking a target does not change the body facing
while the camera is active.

The **Brandish movement keys** preference group uses these defaults:

- W: forward; S: backpedal at half forward speed.
- A/D: turn left/right; Shift+A/D: strafe at 75% forward speed.
- Seated characters follow the seat direction, including pushed chairs and
  wheelchairs. `*spin` turns the on-foot player's camera with the character.

Change these keys in **Game Preferences > Keybindings > Brandish movement
keys**. They may share keys with ordinary movement or other actions; while the
camera is active, Brandish wins, including over special chat macros and in
classic input mode. Two Brandish actions cannot share a key. Rebinding clears
held movement immediately; a physical key-up also releases an explicit modifier
combo. The original movement actions remain independent when Brandish is off.

On the first eligible living-body activation after each global off-to-on switch,
a tgui guide shows the current
six bindings, movement delays, seat/spin behavior and the square view. There is
deliberately no "don't show again" option while the feature is experimental:
every eligible player sees it once per enabled interval. Reopen it with **OOC > Brandish
Perspective Guide**. An activation-local ckey acknowledgement prevents repeated
automatic openings on body transfers, camera recreation or reconnects. Lobby
players, ghosts, excluded bodies and disabled cameras do not open it. Delayed
openings recheck the current body and camera ownership before acknowledging it.

### Preference storage and migration

`SSinput.movement_keys` maps fixed virtual direction names to direction bits.
The physical keys are already rebindable: `move_north`, `move_south`,
`move_west`, and `move_east` are saved as action-to-key arrays in the existing
`key_bindings` preference JSON. On load, missing Brandish forward/back/left/right
actions copy those saved arrays, including deliberately empty arrays. Missing
legacy values use W/S/A/D; missing strafe actions use Shift+A/D. Existing Brandish
bindings are never overwritten. The normal preference write queue persists the
result for new accounts and existing accounts missing the JSON record.
If legacy movement actions already shared a key, their migrated choices are
preserved and the Brandish page flags the duplicates for correction.

The key migration does not change the SQL schema or DB version.

The mode uses a square viewport and composes its offset with other camera
effects. Disabling it removes only its own effect and applies current input
preferences. Login, HUD creation, eye changes and the mob control setters apply
server policy. Remote-control callers must use `set_remote_control()` and
`set_control_object()`; camera lifecycle does not poll SSfastprocess or keyDown.

## Build and verification

The official `dm`, `dm-test`, autowiki and TGS preparation targets generate
shared resources and opt in with `BRANDISH_GENERATED_ICONS`. Run:

```sh
tools/build/build dm
```

Without that define the tracked stub returns an empty catalog. Direct Dream
Maker builds and editor parsing need no generated directory: they retain
original artwork and leave the directional camera disabled. The repository's
existing direct-DM warnings about building TGUI still apply. Defining
`BRANDISH_GENERATED_ICONS` manually requires generating the catalog first:

```sh
node tools/brandish-camera/generate-icons.mjs .
```

| Entry point | Resource behavior |
| --- | --- |
| VSCode F5 / Build All | Existing `preLaunchTask` invokes the build wrapper; generated resources enabled |
| VSCode direct DM task / language server / Test Explorer | Original-art fallback without generated define |
| TGS Windows/Linux PreCompile (`.tgs4.yml`) | TGS target generates catalog and prepends both TGS and generated-resource defines |
| CI normal build / map builds / autowiki | Wrapper generates catalog before compile |
| DreamChecker | Parses the fallback; no ignored include is required |
| CI OpenDream | Explicit generated-resource define after generation |
| Local OpenDream | Fallback by default; generated mode requires generation and explicit define |
| `tools/deploy.sh` | Copies the compiled DMB/RSC; no loose generated assets are required at runtime |

The generator uses Node's standard library and writes content-addressed DMI
files plus a DM catalog under `tmp/brandish-icons`. Source artwork is unchanged;
generated files are ignored by Git. The cache validates inputs, resource hashes
and the catalog hash, including source removals and damaged outputs.

Run the automated resource regression suite after generation:

```sh
node --test tools/brandish-camera/generate-icons.test.mjs
```

It checks original-view pixels and animation metadata, geometry rotation,
connected decals, foreground masks, view gates and cache recovery.

## Appearance policies

`asset-policy.json` declares supported families and explicit exceptions:

The three artwork classes are separate from the rendering mechanism. In
particular, native directional characters already follow `client.dir` and do
not need generated geometry banks.

| Class | Artwork | Handling and policy fields |
| --- | --- | --- |
| 1 | One direction, upright or independent of map orientation | Original artwork. `billboardFiles` explicitly excludes the space background; unselected wall lettering, plaques, posters, painting frames/canvases and talk icons stay native. |
| 2 | One direction, world geometry | `surface` rotates pixels; `smooth`/`corner` select painted connections; `basis` rotates lighting channels. `surfaceStates` separates flat geometry from upright states in mixed files. |
| 3 | Four directions (also eight for diagonal connections) | Upright sprites keep native direction selection. Floor geometry and pipes use directional surface banks (`directionalSurface` prefix rules or `directionalSurfaces` files). |

| Rule or exception | Classes and purpose |
| --- | --- |
| `icons/turf/` | Class 2 single-dir surfaces/connections and class 3 directional floors, decals and walls. Every directional surface preserves the physical frame at NORTH and rotates it for the other views. |
| `icons/obj/` | Smoothing/corner geometry only by default; unrelated upright machines, furniture, signs and items remain native. |
| `icons/misc/Beach/` | Class 2 shoreline smoothing; only fixed sand `Water-0` uses a surface bank. |
| Pipe prefix and explicit atmosphere component files | Class 2 connections/caps and class 3 physical bends. Upright machine bodies remain unchanged. |
| Explicit blood/crayon/dirt/footprint/cable/clockwork/gas-rig files | Flat world art; existing animation, color and movement metadata is retained. |
| `icons/obj/decals.dmi` | Only connected station maps are class 2 surfaces. Single-tile labels and frames are class 1; native direction signs stay directional. |
| `rectangularSurfaces` | Explicit multi-tile geometry, including large airlocks, 2x2/3x3/4x7 structures and 64x32 barsigns. Square padding and native bounds share the original pivot; `footprintMasks` emits only the mask banks actually consumed by large-airlock clipping. |
| `foreground` | Native directional occupied chairs, railings and platforms, with shared perspective occlusion masks. |
| `worldTransforms` | Class 2/3 projectile, beam, lighting and solar geometry; native view gates project arbitrary angles/scales. |

Large upright art is not automatically a surface: the 32x64 ash walker nest and
64x64 talk icons stay native. Two-tile barsigns are connected 64x32 geometry and
use full state banks plus 64x32 native bounds. Posters are 32x32. Unlisted
rectangular geometry and sizes above the declared limits are reported as
excluded rather than silently rotated; new large families need a footprint and
a four-view review.

Four-dir artwork with a diagonal physical `dir` is kept native in diagonal
banks: [BYOND's direction selection](https://www.byond.com/docs/ref/#/atom/var/dir)
depends on the previous orientation in that case. Eight-dir connections have
explicit diagonal banks; no neighboring state's frame is used as a fallback.

`compactSurfaces` applies only to fixed beach sand and connected wall-map states.
Their surface banks omit unselected states, reducing repeated upright artwork.
Every compact-bank lookup supplies the current state; an omitted/unknown state
returns the original file, including when rebinding from a generated bank.
Beach water smoothing retains its complete state set. These families have fixed
states or rebuild their appearances when changed. Do not opt animated/directly
mutated families into compact banks without auditing `icon_state` assignments
and `flick`; other banks intentionally retain all states.

- Surface banks rotate flat artwork; smoothing banks select existing painted
  junctions, including large cells, legacy corners and native directional consoles.
- Foreground masks handle perspective railings and platforms per viewer.
- View gates project world-space rotation and nonuniform scaling for supported
  projectile, muzzle, impact and tracer resources.

Atoms bind shared resources after initialization, appearance updates, smoothing
and physical direction changes. Camera turns do not scan atoms or reassign
terrain icons. Ground decals, underlays and shared vis overlays use the same
registry; GAGS geometry recipes cache coloured banks, including nested references.

Projectile transforms reuse four world overlays per transformed atom. They are
not inserted into `client.images`, and no runtime bitmap rotation is performed.
Use `set_world_transform()` when changing a world-space transform. Keep world
placement and trajectory offsets in `pixel_x/y`; sprite-origin corrections use
`pixel_w/z`. Photo and flat-icon composition include both offset pairs.

New artwork must declare an appropriate policy. Excluded files and reasons are
recorded in the generated manifest; unknown resources retain their original
display. Arbitrary procedural artwork, custom render pipelines, nested GAGS live
editing, all multi-z/vehicle combinations and long-running
GPU/memory performance are outside the current verification coverage.

Clock and incident-display digits use sprite-relative offsets. Stacked direction
labels keep their wall placement in world coordinates and label spacing in
sprite coordinates. Station-map halves, gas-rig sections and cable topology use
shared surface banks; pipe connection bitfields keep their gameplay direction
through a shared explicit-direction overlay. Hydroponics hoses remap connection
states while leaving plant and tray artwork upright.

Occupied chairs use native directional foreground masks instead of changing
their shared layer according to world NORTH. Additive lighting pins its corner
basis independently of turf direction. Pipe gas visuals and layer-adapter
attachments likewise use explicit world directions. Large glass airlocks pad
their rectangular art around the physical footprint and rotate their clipping
mask and sliding parts together. Camera transitions select the existing input
macro set and refresh special chat/Brandish macros for key priority; they do not
erase and rebuild the complete macro sets.

Coordinate changes must state what is being positioned; a global `PIXEL_X`
alias cannot distinguish these cases:

- Map placement, piping layers and a light's cast distance use `pixel_x/y`.
- Sprite elevation and image-origin correction use `pixel_w/z`.
- HUD objects use `screen_loc` or a transform; their pixel offsets are ignored.
- Multi-tile map geometry uses native surface frames aligned to BYOND's
  rotated physical bounds. Do not add another world-center offset. Arbitrary world angles use `set_world_transform()` or an owned
  `world_space_icon` for overlay images.

Atmos component connection states and gas visuals are world geometry. Body and
control artwork stays upright; selected cap/pipe states rotate independently.
Heat-exchange bends support eight physical directions. The multi-deck adapter's
upright riser is deliberately excluded from surface rotation.

Solar panels keep their elevation in screen space and animate four native-gated
visual children per part, recalculating the 2.5D tilt for each viewing direction.
The children are shared world objects; camera turns do not create client images
or scan the scene. Reflector angles and directional beam masks use the same
world projection helper as projectiles. Near-darkness HUD lighting follows the
camera offset through its transform, keeping it centered on the eye's tile.

## Case catalog

The three artwork classes above describe a sprite that is complete inside its
own tile. They are not sufficient on their own: the Advanced Gas Rig showed
that a sprite can look upright in isolation and still have to rotate. Two
questions decide the handling of any asset:

1. **Does the picture depend on anything outside its own tile?** Neighbouring
   pieces, connection directions and smoothing junctions are fixed in map
   space, and map space turns with `client.dir`.
2. **Is the picture wrong, or only where it is drawn?** Many reports were
   offset, angle or draw-order problems on artwork that needed no new pixels.

| Case | Description | Handling | Examples |
| --- | --- | --- | --- |
| A | Self-contained, upright, one direction | Keep original (class 1) | Posters, plaques, items, 32x64 ash walker nest, talk icons, space background |
| B | Self-contained, flat on the ground, one direction | `surface` bank (class 2) | Floors, blood, crayon, footprints, dirt, beach sand |
| C | Self-contained, native four/eight directions | Native `dir` selection; `directionalSurfaces` when flat (class 3) | Mobs, machines, directional floors and decals |
| D | **Multi-tile composite**: several atoms, or one oversized sprite, forming one picture across tiles | Every piece rotates with its tile even if it is drawn upright. `surface` plus `rectangularSurfaces`/`footprintMasks` for non-square art | Gas rig core and ports, station-map halves, large engines (2x2/3x3/4x7), large glass airlock, 64x32 barsign, necropolis stone tiles |
| E | **Direction stored in the state name** while `dir` is 1 or carries gameplay data | Rotate by state; never by `dir`. Pipes draw through a shared explicit-direction overlay | Cables, smart pipes, pipe underlays/caps, layer-manifold attachments, gas visuals |
| F | **Shape chosen by neighbours** | `smooth`/`corner` banks select the painted junction for each heading | Walls, windows, tables, hydroponics hoses, directional consoles |
| G | **Arbitrary world angle or nonuniform scale** | `set_world_transform()` / `world_space_icon` view gates (`worldTransforms`) | Projectiles, tracers, muzzle/impact effects, reflectors, beam light masks, solar panels |
| H | **Correct picture, wrong placement** | Move the offset between coordinate spaces; no generated art | See the offset table below |
| I | **Partly in front of a mob** | `foreground` masks, selected per viewer | Railings, platforms, occupied chair/bench/sofa backrests |
| J | **Colour data indexed by world corner** | `basis` bank rotates the channel layout, not the colours | Static lighting additive underlay |

Case D is a substitute for artwork redrawn per viewing direction. Rotating an
upright piece keeps the composite connected at the cost of its perspective
lying sideways in three of the four headings. Prefer redrawn art where it
exists; do not "fix" the tilt by exempting one piece, which tears the picture.

### Individual exceptions

Each row is a deliberate deviation from the default for its file or type.
Remove or change one only together with a four-heading review.

| Asset | Case | What is special | Where |
| --- | --- | --- | --- |
| Advanced Gas Rig | D | Core, ports and dummies are separate atoms on adjacent tiles; all share one surface bank. Overlays read `icon`, not `initial(icon)`, so they follow the bound bank. Ports use `setDir()` instead of assigning `dir` | `atmospherics/machinery/gasrig.dm`, `files["icons/obj/machines/gasrig.dmi"]` |
| Station map sign | D | Only the connected `map-*` states rotate; every other state in `decals.dmi` is an upright label | `signs/signs_maps.dm`, `surfaceStates["icons/obj/decals.dmi"]`, `compactSurfaces` |
| Large shuttle engines | D | Rotate about BYOND's rotated physical bounds. No additional world-centre offset: one was added once and displaced the sprite twice | `game/shuttle_engines.dm`, `rectangularSurfaces` |
| Large glass airlock | D | 64x32 art padded to square; clipping mask (`footprint` bank) and sliding parts rotate together; parts slide in world `pixel_x/y`, unlike single-tile doors which slide in `pixel_w/z` | `doors/airlock_types.dm`, `effects/overlays.dm` (`world_space_slide`) |
| Barsign | D | Connected two-tile sign with `bound_width = 64`; keeps a complete state bank because `set_sign`/`flick` change state directly | `structures/barsigns.dm` |
| Necropolis stone tile | D | Ruin floor object, not a turf, so it opts in explicitly | `ruins/objects_and_mobs/necropolis_gate.dm` |
| Cable | E | Connection directions are in the state name | `power/cable.dm` |
| Pipe (bitmask) | E | `dir` is a connection bitfield. The atom's own `icon` is set to null and the geometry is a shared overlay with an explicit direction. Code reading `pipe.icon` sees null for these pipes | `pipes/pipes.dm` (`apply_brandish_icon` override, `fixed_surface_overlay`) |
| Device pipe underlays and caps | E | Only the listed cap/pipe states rotate; machine bodies and controls stay upright | `components_base.dm`, `get_pipe_image`, `surfaceStates` for `*_devices.dmi`, `thermomachine.dmi` |
| Multi-deck pipe adapter | E | `pipe-N` states rotate; the upright riser is excluded | `pipes/multiz.dm`, `surfaceStates` for `multiz.dmi` |
| Heat-exchange pipes | C/E | Eight physical directions with explicit diagonal banks | `directionalSurfaces` (`he-*.dmi`) |
| Pipe gas visual | E | Shared object pinned to `dir = NORTH`; it must not inherit a pipe's direction | `atmospherics/machinery/datum_pipeline.dm` |
| Full-tile window | F | Initialised with `setDir(SOUTH)` so directional smoothing art has a cardinal direction | `structures/window.dm` |
| Hydroponics tray | F/H | Hoses are a smoothing family (`base_icon_state = "hoses"`); tray and plant stay upright; vertical origin moved to screen space | `hydroponics/hydroponics.dm` |
| Beach | B/F | Only fixed sand `Water-0` uses a compact surface bank; water smoothing keeps every state | `surfaceStates`, `compactSurfaces` |
| Ground decals | B/C | Separate `/datum/element/decal/ground` so floor paint never shares an item decal's cached appearance; all creation paths go through `add_ground_decal()` | `datums/elements/decals/_decals.dm` |
| Projectiles and effects | G | Trajectory stays in `pixel_x/y`; only the drawn rotation/scale is projected. Four shared overlays per atom, never `client.images` | `projectiles/projectile.dm`, `world_space_icon.dm` |
| Reflector | G | The deflector overlay image owns its own projection | `structures/reflector.dm` |
| Directional/beam light | G/H | Sprite centring is `pixel_w/z`; cast distance is `pixel_x/y`. Mixing both in `transform` moved light along screen axes | `datums/components/overlay_lighting.dm` |
| Solar panel | G | Four gated children per part recompute the 2.5D tilt per heading; elevation is `pixel_z` | `power/solar.dm` |
| Railings and platforms | I | World-direction layer rules replaced by foreground masks. A corner lowered by a mapper (`pixel_y <= -16`) keeps an explicit above-mob overlay | `structures/railings.dm`, `structures/platforms.dm` |
| Chairs, benches, sofas | I | Backrest overlay only while occupied; falls back to the NORTH layer rule without a foreground bank | `beds_chairs/chair.dm` |
| Static lighting underlay | J | Uses the `basis` bank with an empty state and `dir = NORTH` | `lighting/lighting_object.dm` |
| Space background | A | Explicitly excluded from the `icons/turf/` surface rule | `billboardFiles` |
| Ash walker nest | A | 32x64 upright; not padded or rotated | `largeAssetPolicy.billboards` |
| Disposal pipes and construction pieces | C/E | `dir` is a physical dominant direction, unlike atmos bitfields; `dpdir` retains connectivity. Directional surface banks preserve bends, sorting states and flick animations; upright bin/chute/outlet states stay native | `recycling/disposal/pipe.dm`, `construction.dm`, `surfaceStates` |
| Conveyor belts | C/E | Directional surface banks include diagonal and inverted bends plus both animated movement states; control switches stay upright | `recycling/conveyor.dm`, `surfaceStates["icons/obj/recycling.dmi"]` |
| Pinpointer | C | Map and inventory arrows use native eight-direction artwork and are selected per viewer by BYOND; do not rewrite the shared world direction for one client. Inhand artwork is the original generic electronic device | `items/pinpointer.dm`, `icons/obj/device.dmi` |

### Offset exceptions (case H)

`pixel_x/y` is map space and turns with the camera; `pixel_w/z` is screen
space. Each entry states which part belongs to which.

| Asset | World `pixel_x/y` | Screen `pixel_w/z` | Where |
| --- | --- | --- | --- |
| Painting | Wall mounting (+-32) | Canvas origin, runtime PNG, inner frame | `art/paintings.dm` |
| Direction signs | Whole-tile part locating the wall | Sub-tile part stacking labels | `signs/signs_maps.dm` |
| Sign replacement | Copied | Copied as well when a sign is swapped | `signs/_signs.dm` |
| Digital clock, incident display | none | Digit spacing | `machinery/digital_clock.dm`, `incident_display.dm` |
| Trees, stumps, big plants, jungle bushes, rock piles, drake statue, fireplace, gateway, speedwagon | Mapper placement beyond the type default | Type-default origin, via `brandish_screen_origin()` at `Initialize` | `structures/flora.dm`, `fluff.dm`, `fireplace.dm`, `awaymissions/gateway.dm`, `vehicles/speedbike.dm` |
| Cryo cell occupant | none | Height and bobbing animation | `unary_devices/cryo.dm` |
| Jump emote, z-travel animation | none | Vertical hop / rise | `mob/emote.dm`, `multiz/movement/mob/living_zmove.dm` |
| Runechat, balloon alerts | none | Height above speaker and fade travel; `maptext_x/y` stays local | `datums/chatmessage.dm` |
| Progress bar, cogbar, data HUD | none | Height and oversized-icon centring | `datums/progressbar.dm`, `cogbar.dm`, `game/data_huds.dm` |
| Starlight overlay | none | 96x96 centring | `lighting/static_lighting_area.dm` |
| Near-darkness HUD light | not applicable | `screen_loc` objects ignore pixel offsets; the view-sized `transform` is translated | `_onclick/hud/fullscreen.dm` |
| Parallax | not applicable | Layer offsets are reprojected when only the heading changes | `_onclick/hud/parallax.dm` |
| Camera zoom (binoculars, auspex, beam rifle, view zoom) | Zoom look-ahead in a world direction; the third Brandish look-ahead tile | The first two Brandish look-ahead tiles, shake, dizziness | `client/camera_state.dm` |
| Mob base sprite origin | Runtime placement and riding offsets; base world offsets reset to zero at initialization | The declared `base_pixel_x/y` origin, migrated once for every mob | `mob/mob.dm` |
| Table click placement | `camera_click_offset()` converts screen ICON_X/Y into the viewing client's world axes before clamping | Click coordinates remain screen-relative input | `structures/tables_racks.dm`, `camera_coordinates.dm` |
| Team monitor HUD bearing | Target positions stay in world coordinates | `camera_world_angle_to_screen()` projects the owning viewer's angle, including the radial HUD translation | `components/team_monitor.dm` |
| Shiver, sway, tremble and twitch emotes | none | Horizontal sprite motion uses `pixel_w` so EAST/WEST views do not turn it into vertical movement | `mob/living/emote.dm` |

Exporters that flatten appearances (`getFlatIcon`, photos) add both pairs.
`get_oversized_icon_offsets()` treats either pair as an origin correction.

### Adding an asset

1. Answer the two questions above and pick a case.
2. Cases B, D, E, F need a policy entry and, for non-turf atoms, an explicit
   `brandish_icon_mode`. `APPLY_BRANDISH_ICON` skips atoms that have neither a
   mode nor smoothing flags.
3. A mixed file (upright and flat states together) lists its flat states in
   `surfaceStates`. Use `compactSurfaces` only when states are fixed or always
   change through `update_icon`; direct `icon_state` writes and `flick` need a
   complete bank.
4. Case H needs no policy entry: change the offset and add the row above.
5. Add the row to the exception table and review all four headings.

## Review boundaries

The runtime flag controls the camera only. Registry substitutions follow the
generated catalog, not the flag, so a server that never enables the perspective
still renders generated banks at the default heading. For a clean original-art
comparison, build without `BRANDISH_GENERATED_ICONS`; that fallback also keeps
the perspective unavailable.

Backpedal delay (2x), strafe delay (4/3x) and the square viewport are
gameplay/UX changes while the perspective is on and belong in the PR description.
The square view reduces a 19x15 request to 15x15. Generated artwork also increases
the compiled resource package; the merge-review report records measured sizes.
`PRELOAD_RSC` defaults to 0, so package growth is not an unconditional full-package
first-connection transfer; on-demand downloads depend on the visible resources.

DM regressions in `code/modules/unit_tests/brandish_camera.dm` cover coordinate
round trips, missing/disabled and compact-bank fallbacks, camera composition,
key migration/conflicts/modifiers, painting/overhead offsets, independent cogbar
cleanup and directional ground-decal transfer.
They do not substitute for native-client tests of camera ownership and rendering.

Runechat, balloon alerts, progress bars and data-HUD positioning use screen
`pixel_w/z`; their text layout (`maptext_x/y`) stays local to the upright image.
Painting wall placement remains in world `pixel_x/y`, while the runtime PNG and
inner frame use screen offsets. Ash walker stone tiles opt into directional
surface banks. All ground-decal creation paths, including CentCom prison, use
the same four/eight-direction surface policy without map edits.

The second review combined the camera, input/art fixes and initialization/cache
optimizations. The normal build completed with zero errors and warnings; Node
passed 23 tests, the Brandish DM group passed nine, and tgui passed lint,
TypeScript and 57 Jest tests. Native review covered all four camera headings,
runtime painting artwork, overhead text, the guide's current keys and three-tile
description, ash walker ruins, CentCom prison, projectiles and rebuilt smoothing.
The RSC is 235,689,870 bytes, versus 232,041,606 in the preceding review:
6,242,398 bytes of bank savings were outweighed by 9,888,352 bytes of required
directional floor/decal and large-sign additions. Total size reduction remains
unachieved. Complete painting right-click coverage, hardware modifier input,
an authenticated-account reconnect and a full shuttle journey remain unverified.

The following paragraph records the earlier merge review, before these fixes.

Native review exercised two simultaneous clients at NORTH/EAST with chairs,
solar panels, large airlocks, directional lighting, railings/platforms, a laser
projectile and a scaled tracer. Lifecycle probes covered soft critical movement,
incapacitation/recovery, cryo/bed/locker/ATV, remote control, z transfer, key
rebinding, classic input and a client transfer during spin. This is representative
coverage, not certification of every vehicle, shuttle or map interaction.
