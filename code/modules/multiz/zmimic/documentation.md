# Z-Mimic

## How it works

Rather than adding the turf below to the turf above's vis_contents, as previously done, Z-mimic takes a slightly more involved approach in the name of reducing potential maptick and vis_contents use.

Z-Mimic picks up on the appearance of the turf below it, copies it, and tells any atoms on the turfs below to also copy themselves up, making use of the `bound_overlay` var. This shadower copies the icon, direction, and name of the object it is mimicing. The ordering of all of these object and turf appearances is then handled using a set of planes, and the default layer applied to the object. Each z-level is assigned its own plane, and all objects on that z-level are added to the plane, so that each z-level renders in the correct order comparatively. The layers allow things like tables to render in the correct order (their default layers).

The consequence of altering the plane of the object when mimicing it is that any effects (especially overlays) dependent on planes or plane masters will not render properly. Z-Mimic does have built in handling for this, called `ZMM_MANGLE_PLANES`, which will do some plane magic on the object (by rebuilding its overlays with the planes normalized), allowing it to render in the correct order.

### Hooks

Because the mimic is not directly attached to the object it is mimicing, several hooks must be in place to tell the object to update any mimics of itself, using `UPDATE_OO_IF_PRESENT`. The most relevant hooks are:

-   `/atom/movable/Moved()`
-   `/atom/movable/Destroy()`
-   `/atom/movable/Initialize()`
-   `/atom/movable/update_appearance()`
-   `/atom/movable/update_icon()`
-   `/atom/movable/setDir()`
-   `/turf/Initialize()`
-   `/turf/Destroy()`
-   `/turf/ChangeTurf()`
-   `/turf/update_icon()`

Additionally, one of the most important hooks is an override in the SSoverlays queueing system, which can catch many update_icon() misses and other overlay modifications.

What makes Z-mimic so performant is that the performance overhead of checking for an update is extremely minimal, as it's performed on the side of the atom being mimiced, rather than the turf checking on the atom. Caching in `ZMM_MANGLE_PLANES` also helps reduce processing. When Z-mimic is told to update by the mimiced atom, it is queued into the Z-copy subsystem, which then actually performs the atom copies.

### Lighting

Z-Mimic's lighting is relatively simplistic, rather than using the lighting plane, lighting is included on the plane with the atom, and the blend mode is set on the lighting object. All lighting on lower turfs has a color multiplier added to it, causing lower turfs to appear darker. The lighting is placed onto the openspace multiplier atom, which is an internal atom designed to host ambient occlusion, lighting, and apply darkness.

Lighting is copied in the z-copy subsystem during atom copying. If the z-copy subsystem encounters a lighting object, it forwards it to the multiplier via the `copy_lighting` proc. This proc simply copies the appearance of the lighting object, applies a color matrix transformation for darkening, and sets the relevant layers and blend mode onto the multiplier object.

The lighting subsystem then will perform an update on the multiplier whenever it changes a turf that is being mimiced, again reducing overhead. This is done in `lighting_object/proc/update()`, where copy_lighting is directly called onto the `shadower`, which is a direct link to a turf's multiplier object. This part is not queued into the subsystem since that would be a waste of processing.

#### MultiZ Lighting

MultiZ Lighting is only tangentially related to Z-Mimic, however it works by simply adding `update_below_lumcount`, `UPDATE_SUM_LUM` and `UPDATE_ABOVE_LUM`.

`UPDATE_SUM_LUM` determines the turf's current luminosity by using the lum of the turf above and below the current one added. Then, `UPDATE_ABOVE_LUM` is called on the turf above the current one, if any. The turf has its lighting generated using `UPDATE_SUM_LUM` again, and then the turf above also updates the turf below with its own luminosity (via `update_below_lumcount`, again using `UPDATE_SUM_LUM`), if any. Now that both corners are generated `UPDATE_ABOVE_LUM` will not recurse.

### Ambient Occlusion

Adding ambient occlusion to game objects is current done through a client plane master filter adding drop shadow to all objects. Z-Mimic was not designed with this in mind, as planes are used for ordering and not effects, and thus does not support it natively, unless overlay AO is used. This means any objects rendered via Z-mimic will lack any ambient occlusion. This also means that openspace edges will not render darker at the edges, like they previously did. However, a workaround has been made. A drop_shadow added to FLOOR_PLANE means that any edges on the floor plane (openspace) will render a shadow, functionally recreating the drop shadow. However, this may have a negative impact on client performance.

## Types

-   openspace/multiplier -> Applies lighting, darkening, and ambient occlusion to the open space
-   openspace/mimic -> Copies movables on the turf below
-   openspace/turf_proxy -> Holds the appearance of the below turf for non-OVERWRITE Z-turfs (e.g. glass floors)
-   openspace/turf_mimic -> copies openspace/turf_proxy objects

## Terminology

-   Z-Stack
    -   A set of z-connected turfs with the same x/y coordinates.
-   Z-Depth
    -   How many Z-levels this atom is _from the top of a Z-Stack_ (absolute layering), regardless of z-turf presence
-   Shadower / Multiplier
    -   An abstract object used to darken lower levels, copy lighting, and host Z-AO overlays.
-   Mimic / Openspace Object
    -   An abstract object that holds appearances of atoms and proxies clicks.
-   Turf Proxy / Turf Object
    -   An abstract object that holds Z-Copy turf appearances for non-OVERWRITE turfs.
-   Turf Mimic
    -   An abstract object that holds appearances of non-OVERWRITE z-turfs below this z-turf.
-   Foreign Turf
    -   A turf below this z-turf that is contributing to our appearance.
-   Mimic Underlay
    -   A turf appearance holder specifically for fake space below a z-turf at the bottom of a z-stack.

## Public API

### Notifying Z-Mimic of icon updates

-   UPDATE_OO_IF_PRESENT
    -   valid on movables only
    -   if this movable is being copied, update the copies
    -   cheap (if this movable is not being mimiced, this is a null check)
-   atom/update_above()
    -   similar to UPDATE_OO_IF_PRESENT, but for both turfs and movables
    -   less cheap (pretty much just proc-call overhead)

### Checking state

-   TURF_IS_MIMICKING(turf or any)
    -   value: bool - if the passed turf is z-mimic enabled
-   movable/get_associated_mimics()
    -   return: list of movables
    -   get a list of every openspace mimic that's copying this atom for things like animate()

### Changing state

-   turf/enable_zmimic(extra_flags = 0)
    -   return: bool - FALSE if this turf was already mimicking, TRUE otherwise
    -   Enables z-mimic for this turf, potentially adding extra z_flags.
    -   This will automatically queue the turf for update.
-   turf/disable_zmimic()
    -   return: bool - FALSE if this turf was not mimicking, TRUE otherwise
    -   Disables z-mimic for this turf.
    -   This will clean up associated mimic objects, but they may hang around for a few additional seconds.

### Vars

-   turf/z_flags
    -   bitfield
        -   Z_MIMIC_BELOW: Should this turf mimic the below turf?
        -   Z_MIMIC_OVERWRITE: If this turf is mimicking, overwrite its appearance instead of using a mimic object. This is faster, but means the turf cannot have its own appearance.
        -   Z_MIMIC_NO_OCCLUDE: If we're a non-OVERWRITE z-turf, allow clickthrough of this turf. OVERWRITE turfs will have clickthrough by default.
        -   Z_MIMIC_BASETURF: Fake-copy baseturf instead of below turf.
-   atom/movable/z_flags
    -   bitfield
        -   ZMM_IGNORE: Do not copy this atom. Atoms with INVISIBILITY_ABSTRACT are automatically not copied.
        -   ZMM_MANGLE_PLANES: Scan this atom's overlays and monkeypatch explicit plane sets. Fixes emissive overlays shining through floors, but expensive -- use only if necessary.
        -   ZMM_LOOKAHEAD: Look one turf ahead and one turf back when considering z-turfs that might be seeing this atom. Respects dir. Cheap, but not free.
        -   ZMM_LOOKBESIDE: Look one turf to the left and right when considering z-turfs that might be seeing this atom. Respects dir. Cheap, but not free.
        -   ZMM_AUTOMANGLE: Behaves the same as ZMM_MANGLE_PLANES, but is automatically applied by SSoverlays. Do not manually use.

### Z-Mimic: A Practical Guide

#### Update atom's mimic manually

```dm
/obj/thing/proc/changes_how_it_looks()
	transform = matrix(...)
	// Update mimic
	UPDATE_OO_IF_PRESENT
```

#### Atoms that are larger than one turf

```dm
/obj/structure/huge_thing
	plane = MASSIVE_OBJ_PLANE
	// Z-Mimic:
	zmm_flags = ZMM_WIDE_LOAD
```

#### Atoms that use plane effects

```dm
/obj/item/emissive_thing
	zmm_flags = ZMM_MANGLE_PLANES
```

#### Turfs that mimic the turf below

```dm
/turf/open/glass_floor
	z_flags = Z_MIMIC_BELOW
```

#### Turfs that mimic the turf below, and have no sprite

```dm
/turf/open/openspace
	z_flags = Z_MIMIC_BELOW|Z_MIMIC_OVERWRITE
```

## Implementation details

Z-Mimic makes some assumptions. While it may continue to work if these are violated, don't be surprised if it behaves strangely, renders things in the incorrect order, or outright breaks.

### Assumptions

-   Z-Stacks will not be taller than OPENTURF_MAX_DEPTH.
    -   If violated: Warning emitted on boot, layering may break for items near the bottom of the z-stack.
-   Atoms will render correctly if copied to another plane.
-   Atoms will layer correctly if copied to the same plane as other arbitrary in-world atoms.
-   Atoms without ZMM_MANGLE_PLANES do not have any overlays that have explicit plane sets.
    -   If violated: Atoms on the below floor may be partially visible on the current floor.
-   Z-Stacks are 1:1 across the entire x/y plane.
    -   If violated: Z-turfs may form nonsensical connections.
-   Z-Stacks are contiguous and linear -- get_step(UP) corresponds to moving up a z-level (within a z-stack) in all cases.
    -   If violated: layering becomes nonsensical.
-   Z-Stacks will not be changed (note: adding new Z-stacks is OK) after an openturf has been initialized on that z-stack.
    -   If violated: Z-Turfs may act as if they are still connected even though they are not.
-   /turf/space is never above another turf type in the Z-Stack.
-   Turfs that are setting ZM_MIMIC_OVERWRITE do not care about their appearance.
    -   If violated: Appearance of turf is lost.
-   Multiturf movable atoms are symmetric, and centered on their visual center.
    -   If violated: Multitile atoms may not render in cases where they should.
-   SHADOWER_DARKENING_FACTOR and SHADOWER_DARKENING_COLOR represent the same shade of grey.
    -   If violated: unlit and lit z-turfs may look inconsistent with each other.
-   Lighting will mimic correctly without being associated with a plane.
    -   If violated: depending on implementation, lighting may be inverted, or not render at all.
    -   This can usually be addressed by changing /atom/movable/openspace/multiplier/proc/copy_lighting().

### Known Limitations

-   Multiturf movable atoms are not rendered if they are not centered on a z-turf, but overlap one.
-   vis_contents is ignored -- mimics will not copy it.
-   No overlay lighting will render between Zs.
-   Zstacks must be linear in Zs, virtual Zs are unsupported.
-   Performance tradeoff for anything with custom overlay planes (emissives or emissive blockers).
-   Ghost eyes won't allow you to see between totally dark Zs.

## Debugging Tools

There are two verbs added to the Debug table, when mapping verbs are enabled (`Debug verbs-Enable`).

"Analyze Openturf" is added to the right click menu of all turfs, and will show the planes and layering of all zmimic objects for that turf. It is very useful for determining any layering or object visibility issues. It will also tell you the traits of the openturf itself and show all objects rendering in the stack.

"Update all openturfs" forces z-mimic to perform an update for every single mimic. This should help debug if Z-mimic is simply not picking up on an object's existence, or if it's layering incorrectly.
