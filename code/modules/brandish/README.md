# Brandish DM code

The experimental perspective and its rendering helpers live here.

- `camera.dm`: client ownership, movement, seat following and z-look.
- `perspective.dm`: eligibility, round switch and admin verbs.
- `camera_state.dm`: view/effect composition and parallax projection.
- `default_direction.dm`: normal-view default direction and admin verb.
- `observer_mirror.dm`: watched-camera mirroring.
- `guide.dm`, `keybindings.dm`: guide and input preferences.
- `asset_registry.dm`: catalog, fallback and greyscale lookups.
- `appearances.dm`: atom policies and binding.
- `origins.dm`: world/screen origin bookkeeping and resets.
- `world_space_icon.dm`: projected world geometry.
- `coordinates.dm`, `screen_placement.dm`: coordinate and attachment helpers.

Hooks in existing client/atom/gameplay files remain beside their callers.
Normal-view direction traits are cataloged in `code/datums/station_traits/neutral_traits.dm` and exclude Brandish.
Unit tests remain in `code/modules/unit_tests/brandish_*.dm`.
See [the detailed guide](../../../tools/brandish-camera/README.md).
