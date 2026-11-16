# Brandish asset and offset exceptions

See [the current contract](README.md) before adding exceptions.

### Individual exceptions

Each row is a deliberate deviation from the default for its file or type.
Remove or change one only together with a four-heading review.

| Asset | Case | What is special | Where |
| --- | --- | --- | --- |
| Advanced Gas Rig | D | Core, ports and dummies are separate atoms on adjacent tiles; all share one surface bank. Overlays read `icon`, not `initial(icon)`, so they follow the bound bank. Ports use `setDir()` instead of assigning `dir` | `atmospherics/machinery/gasrig.dm`, `files["icons/obj/machines/gasrig.dmi"]` |
| Station map sign | D | Only the connected `map-*` states rotate; every other state in `decals.dmi` is an upright label | `signs/signs_maps.dm`, `files["icons/obj/decals.dmi"].states`, `compact` |
| Large shuttle engines | D | Rotate about BYOND's rotated physical bounds. No additional world-centre offset; native bounds already determine the anchor | `game/shuttle_engines.dm`, `rectangular` |
| Large glass airlock | D | 64x32 art padded to square; clipping mask (`footprint` bank) and sliding parts rotate together; parts slide in world `pixel_x/y`, unlike single-tile doors which slide in `pixel_w/z` | `doors/airlock_types.dm`, `effects/overlays.dm` (`world_space_slide`) |
| Barsign | D | Connected two-tile sign with `bound_width = 64`; keeps a complete state bank because `set_sign`/`flick` change state directly | `structures/barsigns.dm` |
| Necropolis stone tile | D | Ruin floor object, not a turf, so it opts in explicitly | `ruins/objects_and_mobs/necropolis_gate.dm` |
| Cable | E | Connection directions are in the state name | `power/cable.dm` |
| Pipe (bitmask) | E | `dir` is a connection bitfield. The atom's own `icon` is set to null and the geometry is a shared overlay with an explicit direction. Code reading `pipe.icon` sees null for these pipes | `pipes/pipes.dm` (`apply_brandish_icon` override, `fixed_surface_overlay`) |
| Device pipe underlays and caps | E | Only the listed cap/pipe states rotate; machine bodies and controls stay upright | `components_base.dm`, `get_pipe_image`, `states` for `*_devices.dmi`, `thermomachine.dmi` |
| Multi-deck pipe adapter | E | `pipe-N` states rotate; the upright riser is excluded | `pipes/multiz.dm`, `states` for `multiz.dmi` |
| Heat-exchange pipes | C/E | Eight physical directions with explicit diagonal banks | `directional` (`he-*.dmi`) |
| Pipe gas visual | E | Shared object pinned to `dir = NORTH`; it must not inherit a pipe's direction | `atmospherics/machinery/datum_pipeline.dm` |
| Full-tile window | F | Initialised with `setDir(SOUTH)` so directional smoothing art has a cardinal direction | `structures/window.dm` |
| Hydroponics tray | F/H | Hoses are a smoothing family (`base_icon_state = "hoses"`); tray and plant stay upright; vertical origin moved to screen space | `hydroponics/hydroponics.dm` |
| Beach | B/F | Only fixed sand `Water-0` uses a compact surface bank; water smoothing keeps every state | `states`, `compact` |
| Ground decals | B/C | Separate `/datum/element/decal/ground` so floor paint never shares an item decal's cached appearance; all creation paths go through `add_ground_decal()` | `datums/elements/decals/_decals.dm` |
| Projectiles and effects | G | Trajectory stays in `pixel_x/y`; only the drawn rotation/scale is projected. Four shared overlays per atom, never `client.images` | `projectiles/projectile.dm`, `world_space_icon.dm` |
| Reflector | G | The deflector overlay image owns its own projection | `structures/reflector.dm` |
| Directional/beam light | G/H | Sprite centring is `pixel_w/z`; cast distance is `pixel_x/y`. Mixing both in `transform` moved light along screen axes | `datums/components/overlay_lighting.dm` |
| Solar panel | G | Four gated children per part recompute the 2.5D tilt per heading; elevation is `pixel_z` | `power/solar.dm` |
| Railings and platforms | I | World-direction layer rules replaced by foreground masks. A corner lowered by a mapper (`pixel_y <= -16`) keeps an explicit above-mob overlay | `structures/railings.dm`, `structures/platforms.dm` |
| Chairs, benches, sofas | I | Backrest overlay only while occupied; falls back to the NORTH layer rule without a foreground bank | `beds_chairs/chair.dm` |
| Static lighting underlay | J | Uses the `basis` bank with an empty state and `dir = NORTH` | `lighting/lighting_object.dm` |
| Space background | A | Explicitly excluded from the `icons/turf/` surface rule | `billboardFiles` |
| Ash walker nest | A | 32x64 upright; not padded or rotated | Keep native upright artwork |
| Disposal pipes and construction pieces | C/E | `dir` is a physical dominant direction, unlike atmos bitfields; `dpdir` retains connectivity. Directional surface banks preserve bends, sorting states and flick animations; upright bin/chute/outlet states stay native | `recycling/disposal/pipe.dm`, `construction.dm`, `states` |
| Conveyor belts | C/E | Directional surface banks include diagonal and inverted bends plus both animated movement states; control switches stay upright | `recycling/conveyor.dm`, `surfaceStates["icons/obj/recycling.dmi"]` |
| Spacevine and planted kudzu coverage | B | Light/Med/Hvy are flat ground coverage, not a directional connection graph. Only these nine states rotate; Venus human trap and its upright buds remain native | `events/spacevine.dm`, `surfaceStates["icons/effects/spacevines.dmi"]` |
| Drake and bubblegum landing telegraph | B/H | Rotate only the additional `landing` state in the compact 96px effect bank; centre its canvas in screen coordinates while retaining its actual target tile | `megafauna/drake.dm`, `surfaceStates["icons/effects/96x96.dmi"]` |
| Flying point arrow | B/G | Only the arrow state uses a compact surface bank. Its world trajectory and animated uniform rotation compose with the per-view bitmap rotation; other HUD states remain native | `point/point.dm`, `surfaceStates["icons/hud/screen_gen.dmi"]` |
| Shipping containers, rug, RBMK, DNA vault, bluespace tap, BSA and dead Ratvar | B/D/G | `projection: geometry` keeps the original rectangular canvas, map pixel offsets and physical bounds. Four sparse ordinary overlays rotate the canvas centre and compensate the native bounds anchor. RBMK tops and BSA tops/charge overlays use the same projector. No vis_contents or runtime bitmap rotation | `world_space_icon/geometry`, `brandish_geometry_overlay()`, policy `projection: geometry` |
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
| Camera zoom (binoculars, auspex, beam rifle, view zoom) | Zoom look-ahead in a world direction; the third Brandish look-ahead tile | The first two Brandish look-ahead tiles, shake, dizziness | `code/modules/brandish/camera_state.dm` |
| Mob base sprite origin | Runtime placement and riding offsets; base world offsets reset to zero at initialization | The declared `base_pixel_x/y` origin, migrated once for every mob | `mob/mob.dm` |
| Mob base values after follow-up | Supersedes the reset-to-zero description above: public `base_pixel_x/y` keep their original values; `get_world_base_pixel_x/y()` subtract the migrated origin when composing world placement | The migrated origin is stored separately, preserving setter, serialization and NORTH/off behavior | `mob/mob.dm`, `living_update_icons.dm` |
| Morph, mimite and illusion copies | Copying retains each creature's original base placement | `reset_pixel_origin()` restores its own screen origin as well, preventing a copied large mob's origin from leaking into restored forms | `morph/morph.dm`, `hostile/mimite.dm`, `hostile/illusion.dm` |
| Small sprite toggle | Override image cancels the mob's world offsets | Override image also cancels `pixel_w/z`; otherwise a migrated large origin displaces the 32x32 replacement | `actions/mobs/small_sprite.dm` |
| Table click placement | `camera_click_offset()` converts screen ICON_X/Y into the viewing client's world axes before clamping | Click coordinates remain screen-relative input | `structures/tables_racks.dm`, `modules/brandish/coordinates.dm` |
| Team monitor HUD bearing | Target positions stay in world coordinates | `camera_world_angle_to_screen()` projects the owning viewer's angle, including the radial HUD translation | `components/team_monitor.dm` |
| Bloodsense HUD bearing | Target bearing stays in world coordinates until projection | Use the owning client's heading before updating the HUD rotation; the same target can appear on different screen sides for different viewers | `_onclick/hud/alert.dm` |
| Shiver, sway, tremble and twitch emotes | none | Horizontal sprite motion uses `pixel_w` so EAST/WEST views do not turn it into vertical movement | `mob/living/emote.dm` |
| Plate and griddle contents | none: placement is local to the upright artwork | `screen_placement` transfers the existing item offsets to `pixel_w/z` while attached, restores them on removal, and preserves griddle recipe placement | `plate.dm`, `griddle.dm`, `modules/brandish/screen_placement.dm` |
| Bonfire grill, xenoarchaeology scale, crayon marks and laser pointer | World surface placement from `camera_click_offset()`; full map-click vectors include target origins | none | `bonfire.dm`, `xenoarchaeology_machines.dm`, `crayons.dm`, `laserpointer.dm` |
| Sticker attachment points | Surface/smoothing parents keep the inverse-projected attachment in `pixel_x/y` | Upright parents keep their attachment in `pixel_w/z` | `items/sticker/sticker.dm` |
| Diagonal railing vault | The original drag offset is inverse-projected before choosing the physical edge | none; save the drag's camera heading across the climbing delay | `elements/climbable.dm` |
| Living offset sources | Explicit x/y retain physical tile placement, grabs and attack vectors | Explicit w/z compose upright alignment, lying and height. Constant height across four physical riding headings is separated; asymmetric pose tables still require review | `living_update_icons.dm`, `components/riding/riding.dm` |
| Float, waddle, jitter and stun | Preserve the existing world placement | Screen motion restores the migrated origin plus all active screen-height sources; immersion masks consume the same screen height | `visual_effects.dm`, `waddling.dm`, `jitteriness.dm`, `immerse.dm` |
| Fulton and noose | Extraction travel between turfs and mapper placement remain in world axes | Balloon ascent, attachments, hanging height and sway use screen axes. The original unbuckled noose anchor is preserved | `mining/fulton.dm`, `objects/noose.dm` |
| Drake flight | Retain the flight's target-directed world X trajectory, including the original NORTH endpoints | The 64px canvas origin moves to pixel_w independently of the flight's pixel_z elevation | `megafauna/drake.dm` |
| Singularity and Tesla | Logical tile centre and zap source stay in world axes | Canvas centring uses screen axes. Singularity expansion removes the previous origin before replacing it, including repeated growth/shrink cycles | `power/singularity/singularity.dm`, `power/tesla/energy_ball.dm` |
| Point thought bubble | Point travel remains a world vector | Bubble offset is screen right16/up32; copied item origins are cleared on all four axes. Existing vis_contents transport is retained | `point/point.dm` |
| MOD sphere transform | Rolling travel remains on world tiles | The module's -4px body height uses the common screen-height offset source, removed on deactivation | `mod/modules/modules_supply.dm` |
| Elite tumor | Runtime base-pixel edits retain their original world deltas and public values | Explicit `from_base` moves the declared -16px canvas origin to screen X; non-mob world-base getters exclude only this opted-in origin | `elites/elite.dm`, `brandish_screen_origin()` |
| Riding parent canvas origins | Physical pose offsets remain in world axes | Normalize legacy non-living parent tables against their existing screen origin before separating constant height; the car's -48px origin must not be added twice | `components/riding/riding.dm` |
| Local copied-appearance previews | Clear source world placement before applying local placement | Clear source screen origin too; preview/bag/tool/apparatus copies must not move the live source | `copy_appearance_without_offsets()`, `icons.dm`, `evidence.dm`, `tools.dm`, `ghettobomb.dm`, `robot_items.dm` |

Exporters that flatten appearances (`getFlatIcon`, photos) add both pairs.
`get_oversized_icon_offsets()` treats either pair as an origin correction.

### Geometry and bounds cases

| Asset family | Case | Geometry and appearance policy |
| --- | --- | --- |
| Incident displays (bridge/delamination, advertisements, frame and emissive art) | D | Connected 64x32 panel and native 64x32 bounds; digit `pixel_x/y` belongs to the panel's world geometry. Directional-helper wall placement remains in world coordinates. |
| Gateway | D/G | Preserve the original 96x64 collision box and entry row. Four sparse ordinary overlays project the complete 96x96 art and compensate native collision-anchor movement. Both `off` and animated `on` states share this path; overlays retain the gateway's click identity and are included in appearance copies. No visual child is used. |
| Gravity generator | D | All nine tile-sized machinery parts bind the same surface family, including their state changes. |
| Necropolis gate, arch, blocker and opening/closing effects | D/B | Selected 96x96/160x160 geometry states use compact banks; all door animation frames remain present. Unrelated explosions/effects retain their source files. The arch's extra 24px elevation stays in world space. |
| Fixed closed turfs, including legacy Abductor and shuttle walls | B/C | `/turf/closed` opts into world surfaces. Smoothing/corner families still take precedence. Abductor `alien1` through `alien24` are fixed map states, not diagonal smoothing. |
| Plumbing ducts | E | State names encode connection bits; a shared overlay explicitly anchored to NORTH rotates the topology without mutating `dir` or `connects`. Multilayer ducts retain their 1px placement beyond the centred 64px canvas. |
| Plumbing fixed supply/demand connectors | E | Only the eight single-direction `*-s` connector states rotate. Native four-direction connectors and upright machine bodies keep their original behavior. |
| `Beam()` segments (Tesla/supermatter, medical beams, chains, tethers and vines) | G | World positions stay in `pixel_x/y`. Project the shared full-segment drawing and its emissive pass; crop cached terminal view gates before applying the world transform, then reattach their appearances. Custom xenoartifact beam art is included. |
| BoxStation bar glass and wood siding | B/C/F | The six reinforced-glass tiles at (140..145,136) also contain wood-siding decals. The wood trim rotates from a horizontal edge to a vertical edge; layer isolation distinguishes it from glass, starlight and static lighting. Keep that mapped decoration. |
| Wizard's Den ordinary propulsion engines | C/B | Their protrusion beyond the hull is present in the original map. Existing directional surface binding rotates the engines and lava with the ship; fixed surrounding closed turfs use the common policy above. |

| Origin correction | World offsets retained | Screen offsets |
| --- | --- | --- |
| Gateway | Mapper placement and collision/portal coordinates | 96px canvas centring; per-view ordinary overlays additionally compensate the 96x64 collision anchor |
| Necropolis gate / blocker / transition effects | Blocker's separate sight-blocking tile and its world displacement | 96px canvas centring (-32,-32) |
| Necropolis arch | 24px elevation beyond its centred canvas | 160px canvas centring (-64,-64) |
| Multilayer plumbing duct | Original 1px residual placement | 64px canvas centring (-16,-16) |

Ordinary overlays are part of `appearance`; `vis_contents` is not. Gravity
generator and necropolis corrections do not use visual contents. Gateway art
uses ordinary overlays. Full `Beam()` segments retain their pre-existing shared
visual-content drawing; terminal segments use ordinary projected overlays.
An appearance-copy regression verifies retained gateway art. Multi-z review
confirmed that a mimic also needs the original rendering bounds: copying only
the appearance leaves gateway, barsign and large-engine drawings displaced in
quarter/half turns. `sync_display_bounds()` now synchronises all four bounds
fields before assigning the copied appearance, including recursive mimics.
Gateway-specific opposite offsets are inappropriate.


## Artwork decisions

Upright single-direction artwork stays native, including large talk bubbles,
ash walker nests, wall lettering, frames and scene backgrounds. Large dimensions
alone never imply world geometry. Native four/eight-direction upright sprites
also need no bank: client.dir already selects their displayed direction.

Rectangular world art is padded only when explicitly opted in, retaining the
original pivot and native bounds. Two-tile barsigns keep complete state banks
because set_sign/flick may change states directly. Unlisted geometry is reported.

Mixed files rotate only selected surface states. Wall lettering and frames in
icons/obj/decals.dmi remain upright while connected station maps rotate.
Compact banks cover fixed sand, connected maps and necropolis gate/arch art;
all bound door, transition and blocker states must remain present. Lookups supply
the current state and return the source file for omitted states. Other animated
or directly mutated families retain complete banks.
