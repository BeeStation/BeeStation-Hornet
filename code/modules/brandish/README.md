# Brandish DM code

The experimental perspective and its rendering helpers live here.

- `brandish_camera.dm`: client ownership, movement, seat following and z-look.
- `brandish_perspective.dm`: eligibility, round switch and admin verbs.
- `brandish_camera_state.dm`: view/effect composition and parallax projection.
- `brandish_default_direction.dm`: normal-view default direction and admin verb.
- `brandish_observer_mirror.dm`: watched-camera mirroring.
- `brandish_guide.dm`, `brandish_keybindings.dm`: guide and input preferences.
- `brandish_asset_registry.dm`: catalog, fallback and greyscale lookups.
- `brandish_icon_mode.dm`: atom binding and bulk type defaults.
- `brandish_image.dm`: shared upright, wall_mounted and group_rotate setup.
- `brandish_origins.dm`: world/screen origin bookkeeping and resets.
- `brandish_image_projector.dm`: projected world geometry.
- `brandish_coordinates.dm`, `brandish_screen_placement.dm`: coordinate and attachment helpers.

Special types declare `brandish_image = /datum/brandish_image/upright` (or another case).
`InitAtom` consumes it once after successful initialization; later updates use instance fields.
Keep origins in the caller when Initialize/LateInitialize needs the adjusted pixels before returning.
Dynamic resizing, occupancy masks and bulk floor/wall defaults remain at their callers.
Normal-view direction traits are cataloged in `code/datums/station_traits/neutral_traits.dm` and exclude Brandish.
Unit tests remain in `code/modules/unit_tests/brandish_*.dm`.

| Case | Meaning | Mode (`brandish_icon_mode`) | Init policy (`brandish_image`) |
| --- | --- | --- | --- |
| `rotate` | Rotate flat ground artwork | `BRANDISH_MODE_ROTATE` | none |
| `group_rotate` | Rotate multi-tile artwork together with its bounds | `BRANDISH_MODE_GROUP_ROTATE` | `/datum/brandish_image/group_rotate` |
| `connected` | Orientation encoded in state names (`dir` holds connections) | `BRANDISH_MODE_ROTATE` or `BRANDISH_MODE_CONNECTED` | type's `brandish_connection_icon` |
| `upright` | Keep art upright; move canvas origin to screen space | depends on art | `/datum/brandish_image/upright` |
| `wall_mounted` | Separate whole-tile wall anchor from sub-tile stacking | depends on art (`BRANDISH_MODE_ROTATE` for station maps) | `/datum/brandish_image/wall_mounted` |
| `smooth` / `corner` | Select neighbour-joined artwork | automatic from smoothing flags | none |
| (arbitrary angle) | Projectiles, beams, etc. | none | `set_brandish_transform()` → `/datum/brandish_image_projector` |

See [the detailed guide](../../../tools/brandish-camera/README.md).
