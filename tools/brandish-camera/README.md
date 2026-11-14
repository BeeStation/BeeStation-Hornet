# Brandish camera and directional assets

The forward-facing camera is enabled by default for living players, including
soft critical health. Lobby players, dead bodies and ghosts are excluded.
Unconsciousness and hard critical health pause input while retaining the same
view direction and offset. Remote control releases the camera; returning to
direct control creates it again. A native eye on the body's containing locker,
cryo cell, carrier or vehicle remains a local view and preserves the camera.

For this test merge, Brandish is always enabled regardless of the
`BRANDISH_CAMERA` configuration value (including `0` or an omitted entry).
The option is retained for configuration compatibility. Debug administrators
can opt their current body out through **Debug > Brandish Camera**.

The camera looks two tiles ahead, keeps the character below center, and turns
in 90-degree steps. Look-ahead uses a constant screen-space offset, so turning
does not also interpolate the camera's world position. Shake and dizziness own
separate effects and cannot restore an obsolete camera position. The two-tile
lead avoids exposing a missing top row after movement on BYOND 516.

The normal rebindable movement actions use these default keys:

- W: forward; S: backpedal at half forward speed.
- A/D: turn left/right; Shift+A/D: strafe at 75% forward speed.
- Seated characters follow the seat direction, including pushed chairs and
  wheelchairs. `*spin` turns the on-foot player's camera with the character.

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
macro set; they do not rebuild and resend every key binding.

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

## Review boundaries

The test merge ignores `BRANDISH_CAMERA`; configuration changes do not disable
client cameras or registry substitution. Original-art fallback still applies
when the build has no generated catalog.

Backpedal delay (2x), strafe delay (4/3x), the square viewport, and the enabled
server default are gameplay/UX changes and belong in the PR description.
The square view reduces a 19x15 request to 15x15. Generated artwork also increases
the compiled resource package; the merge-review report records measured sizes.
`PRELOAD_RSC` defaults to 0, so package growth is not an unconditional full-package
first-connection transfer; on-demand downloads depend on the visible resources.

DM regressions in `code/modules/unit_tests/brandish_camera.dm` cover coordinate
round trips, missing/disabled catalog fallbacks and effect restoration/composition.
They do not substitute for native-client tests of camera ownership and rendering.

Native review exercised two simultaneous clients at NORTH/EAST with chairs,
solar panels, large airlocks, directional lighting, railings/platforms, a laser
projectile and a scaled tracer. Lifecycle probes covered soft critical movement,
incapacitation/recovery, cryo/bed/locker/ATV, remote control, z transfer, key
rebinding, classic input and a client transfer during spin. This is representative
coverage, not certification of every vehicle, shuttle or map interaction.
