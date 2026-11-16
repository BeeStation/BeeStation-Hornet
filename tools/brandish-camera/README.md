# Brandish perspective: current contract

Brandish is an experimental, forward-facing view implemented with `client.dir`.
It turns the map in quarter turns while shared directional artwork keeps world
connections aligned. It is **off at round start** and has no enabling config key.

Code navigation is in [the module index](../../code/modules/brandish/README.md).
Asset-specific and offset exceptions are in [EXCEPTIONS.md](EXCEPTIONS.md).

## Operation and input

Admins (`R_ADMIN`) and coders (`R_DEBUG`) can use **Toggle Brandish Perspective**.
It enables the perspective for eligible living players, including soft critical.
The **Brandish Camera** verb opts the current body out or back in.

Lobby players, ghosts, dead bodies, silicons, brains and shades are excluded.
A mind inside a carried item is excluded; lockers, cryo, vehicles and mechs are
local containers and retain the camera. Remote control releases camera ownership.
Returning to direct control recreates it. Incapacitation pauses input without
changing the retained view. Observe mirrors the watched camera's view and heading.

The camera looks two tiles ahead and keeps the body below screen center.
Look-ahead uses screen coordinates only: turning never changes camera offsets.
More than two screen tiles clips rotated views; world offsets can lag a turn by
one frame. Observe uses the same two-tile screen offset.
The logical viewport is square: the shorter dimension of a requested view wins.
Backpedal takes twice the normal delay; strafe takes four thirds of that delay.

The guide displays the player's **current** movement bindings. Defaults provide
forward/backpedal, left/right turn and modified left/right strafe. Rebind them in
Game Preferences > Keybindings > Brandish movement keys. Ordinary movement and
other actions can share these keys; Brandish wins while its camera owns input.
Two Brandish actions cannot share a binding. Classic input mode is supported.
Key-up releases held commands, and rebinding clears them immediately.

Seated players follow the seat's physical direction. Spin rotates the on-foot
view. Clicking a target does not change facing while the camera is active.
The guide opens once per eligible activation interval and can be reopened through
**Brandish Perspective Guide**. Reconnects and body transfers do not repeat an
acknowledged introduction. There is no permanent opt-out while experimental.

### Normal-view direction traits

**Set Default Client Direction** is for normal view with Brandish disabled.
It selects neutral, weight-zero station traits for SOUTH/EAST/WEST, replacing any
previous direction trait. NORTH means no trait. Random selection excludes zero
weights. Current and future clients derive their default from the active trait.

Pass NORTH/SOUTH/EAST/WEST or 1/2/4/8 to the verb, or choose through its prompt.
The existing station-trait panel can schedule these subtypes for the next round.
Direction traits and Brandish are mutually exclusive; remove the trait by choosing
NORTH before enabling Brandish, or disable Brandish before adding a trait.

## Building, fallback and deployment

Use the normal build wrapper:

```sh
tools/build/build dm
```

Its DM, DM-test, autowiki and TGS targets run the generator and define
`BRANDISH_GENERATED_ICONS`. VSCode Build All/F5 uses the wrapper. CI normal/map
builds do likewise; OpenDream CI explicitly defines generated-resource support.

Direct Dream Maker, language-server parsing, Test Explorer and local OpenDream
without that define use the tracked empty-catalog stub. They need no generated
directory, retain original artwork and cannot enable the directional camera.
Defining generated support manually requires first running:

```sh
node tools/brandish-camera/generate-icons.mjs .
```

Only Node standard-library code is needed. Outputs under `tmp/brandish-icons`
are ignored by Git. Content-addressed DMI files are shared, and source art is
unchanged. The cache validates source inputs, output hashes and the DM catalog,
including source removal and corrupted files. Do not prune the shared cache.

The compiled RSC supplies client art. Server-side rust-g metadata and
IconForge/GAGS geometry loaders also need the generated files on disk.
Deploy the completed manifest's referenced DMI resources using the deployment
scripts. Staging may prune obsolete generated files **inside its own destination**;
it must not delete source-cache resources or copy every stale cached DMI.

Camera enable/disable controls perspective, not registry substitutions. Generated
banks remain bound while the camera is off. NORTH retains the original view;
use a build without the generated define for an original-art diagnostic baseline.

## Coordinate and appearance rules

First ask: **does this picture depend on the world outside its tile?** Then ask:
**is the error in the picture, its position, its angle or its draw order?**
Do not add banks to fix an offset, and do not exempt one connected geometry part.

| Value | Meaning |
| --- | --- |
| `pixel_x/y` | World placement, trajectory and tile-direction movement; rotates with the map |
| `pixel_w/z` | Upright sprite origin and elevation; stays in screen axes |
| `screen_loc` / HUD transform | Screen placement and HUD bearing; use screen view dimensions |
| `maptext_x/y` | Local text layout inside an upright appearance |
| Native bounds | Physical footprint and rotated bitmap anchor; preserve gameplay bounds |

`camera_world_to_screen` and `camera_screen_to_world` convert vectors, not tiles.
`camera_click_offset` converts screen click coordinates when storing world offsets.
Placement inside upright art uses screen axes instead; screen_placement restores
an item's previous four offsets when it leaves the surface.

`brandish_screen_origin` migrates an artwork-origin delta and records it.
Public base_pixel values retain their meaning; world-base getters exclude the
migrated origin. Living offsets compose independent movement/elevation sources.
Photo/flat-icon and small-preview consumers must account for both offset pairs.

Logical views are screen-relative. At EAST/WEST a 17x15 screen view is applied as
15x17 to BYOND. Use `screen_view()` for HUD and click projection; native view(),
AI visibility and other world-space consumers keep the applied world rectangle.

Camera effects have independent source ownership. Body changes clear effects and
invalidate pending callbacks. Effect epochs and sway generations serve different
lifetimes; neither stale timers nor an old client may restore a newer view.

### Case summary

| Case | Picture or problem | Handling |
| --- | --- | --- |
| A | Self-contained upright art | Native resource, even when oversized |
| B | Flat ground art | Surface bank |
| C | Native directional art | Native upright frames; directional banks only for world surfaces |
| D | Connected or multi-tile geometry | Rotate every piece; explicit rectangular/footprint policy |
| E | Connections encoded in state names or gameplay dir bits | Rotate state topology without changing gameplay direction |
| F | Neighbour-selected shape | Smooth/corner banks |
| G | World angle or nonuniform scale | World transform through sparse view gates |
| H | Correct picture at the wrong offset | Correct coordinate axes; no new art |
| I | Part of art occludes a mob | Native directional foreground mask |
| J | Colour channels indexed by world corner | Basis bank |

The detailed table records deliberate perspective compromises and exceptions.
Case D may tilt upright pieces to keep a composite connected; use redrawn native
art when available. Splitting a composite's policy tears it at tile boundaries.

## Asset policy and contribution path

Prefix rules supply defaults. Each path has one `files[path]` options record. Surface
state selection and compactness are different decisions: selection chooses what
rotates; compactness omits other states and requires state-aware source fallback.

1. Choose the case from the two questions above; inspect native dir/state metadata.
2. Add one `files[path]` record: `modes` selects surface/smooth/corner/basis;
   `rectangular` opts into padding, `directional` into native surface directions.
   `states` selects flat states; `compact` omits the others; `footprint` emits masks.
   `projection` is transform or geometry; `foreground` names an occlusion family;
   `exclude` records upright art. Prefix `rules` and `limits` supply shared defaults.
3. Non-turf world art needs an explicit `brandish_icon_mode` or smoothing flags.
4. Use `APPLY_BRANDISH_ICON` at new binding sites. Retain Initialize, state update,
   physical direction and smoothing entry points; they cover different events.
5. Mixed files select surface states. Compact banks require fixed states or audited
   update_icon paths; direct icon_state writes and flick usually need full banks.
6. Rectangular art needs explicit geometry and footprint decisions. Large upright
   art remains native. Unlisted geometry and size-limit exclusions are reported.
7. World-angle changes use `set_world_transform()` or an owned world_space_icon;
   trajectory offsets remain world coordinates and sprite origins remain screen.
8. Add the reason to EXCEPTIONS.md and check NORTH/off plus all four camera views.

Eight-direction surfaces have explicit diagonal banks. Four-direction art with a
diagonal physical dir retains native selection in diagonal banks because BYOND
uses previous orientation for undefined diagonals; never read a neighbouring state.

State topology overlays use explicit NORTH: SOUTH would inherit the parent's dir.
Shared cached images must not receive device-local colour/layer changes; request
a fresh appearance for those. GAGS recipes retain logical source recovery and
cache coloured geometry without per-viewer bitmap generation.

Ordinary overlays survive appearance copies; vis_contents do not. Multi-tile
mimics also need synchronized display bounds before appearance assignment.
Dirty state and input caches are separate: clearing overlays must invalidate a
projector even if its source/state/transform are unchanged. Camera turns themselves
do not scan atoms or rebind terrain. Four native gates select the visible view.

## Verification

```sh
node --test tools/brandish-camera/generate-icons.test.mjs
tools/build/build dm
```

Run Brandish DM unit groups both with and without generated support, tgui
TypeScript/eslint and ticked-file enforcement. Inspect **all** execution logs,
including dd.log, for runtime errors and stack traces; a test PASS alone is not
proof of clean execution. Check native clients for ownership and renderer behavior.
Review connected walls/windows, pipes/cables, large bounds, beams, oversized mobs,
riding, z-look return, Observe and normal-view E/W traits in all relevant views.

## Known limitations and boundaries

Asymmetric riding pose/layer tables are not viewer-relative. Riders can miss the
visible seat or sort incorrectly after rotation, including janicart, speedbike
and multi-seat speedwagon. Brandish remains enabled while mounted. A complete
mounted presentation design is separate work; shared offsets cannot express it.

Pinpointers keep existing in-hand art. Floor icons and HUD slot needles provide
tracking; no extra in-hand needle is planned here.

The existing z-mimic path omits vis_contents: solar panels, airlock doors/frames,
full beam spans and lower-floor runechat/progress/cog displays may be absent above.
Copying these visual children is outside this PR. Weeds and clockwork lattice or
catwalk can also retain a blank upper mimic after asynchronous smoothing; this
predates Brandish and a source-copy refresh restores it.

Arbitrary procedural art, custom render pipelines, nested live GAGS editing,
every multi-z/vehicle combination and long-running GPU/memory behavior need
separate review. Representative tests do not certify every asset or shuttle trip.
