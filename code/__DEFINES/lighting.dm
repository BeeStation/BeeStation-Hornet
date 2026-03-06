///Object doesn't use any of the light systems. Should be changed to add a light source to the object.
#define NO_LIGHT_SUPPORT 0
///Light made with the lighting datums, applying a matrix.
#define STATIC_LIGHT 1
///Light made by masking the lighting darkness plane.
#define MOVABLE_LIGHT 2
///Light made by masking the lighting darkness plane, and is directional.
#define MOVABLE_LIGHT_DIRECTIONAL 3

///Is a movable light source attached to another movable (its loc), meaning that the lighting component should go one level deeper.
#define LIGHT_ATTACHED (1<<0)

///This light doesn't affect turf's lumcount calculations. Set to 1<<15 to ignore conflicts
#define LIGHT_NO_LUMCOUNT (1<<15)

#define MINIMUM_USEFUL_LIGHT_RANGE 1.4

/// light UNDER the floor. primarily used for starlight, shouldn't fuck with this
#define LIGHTING_HEIGHT_SPACE -0.5
/// light ON the floor
#define LIGHTING_HEIGHT_FLOOR 0
/// height off the ground of light sources on the pseudo-z-axis, you should probably leave this alone
#define LIGHTING_HEIGHT 1
/// Value used to round lumcounts, values smaller than 1/129 don't matter (if they do, thanks sinking points), greater values will make lighting less precise, but in turn increase performance, VERY SLIGHTLY.
#define LIGHTING_ROUND_VALUE (1 / 64)

/// icon used for lighting shading effects
#define LIGHTING_ICON 'icons/effects/lighting_object.dmi'

/// If the max of the lighting lumcounts of each spectrum drops below this, disable luminosity on the lighting objects.
/// Set to zero to disable soft lighting. Luminosity changes then work if it's lit at all.
#define LIGHTING_SOFT_THRESHOLD 0

/// If I were you I'd leave this alone.
#define LIGHTING_BASE_MATRIX \
	list                     \
	(                        \
		1, 1, 1, 0, \
		1, 1, 1, 0, \
		1, 1, 1, 0, \
		1, 1, 1, 0, \
		0, 0, 0, 1           \
	)                        \

#define LIGHT_RANGE_FIRE		3 //! How many tiles standard fires glow.

#define ADDITIVE_LIGHTING_PLANE_ALPHA_MAX 255
#define ADDITIVE_LIGHTING_PLANE_ALPHA_NORMAL 128
#define ADDITIVE_LIGHTING_PLANE_ALPHA_INVISIBLE 0

#define LIGHTING_PLANE_ALPHA_VISIBLE 255
#define LIGHTING_PLANE_ALPHA_NV_TRAIT 250
#define LIGHTING_PLANE_ALPHA_MOSTLY_VISIBLE 192
#define LIGHTING_PLANE_ALPHA_MOSTLY_INVISIBLE 128 //! For lighting alpha, small amounts lead to big changes. even at 128 its hard to figure out what is dark and what is light, at 64 you almost can't even tell.
#define LIGHTING_PLANE_ALPHA_INVISIBLE 0

//lighting area defines
#define DYNAMIC_LIGHTING_DISABLED 0 //! dynamic lighting disabled (area stays at full brightness)
#define DYNAMIC_LIGHTING_ENABLED 1 //! dynamic lighting enabled
#define IS_DYNAMIC_LIGHTING(A) A.dynamic_lighting

// Fullbright lighting defines
#define FULLBRIGHT_NONE 0		//! Do not use fullbright (Only applies to turfs)
#define FULLBRIGHT_DEFAULT 1	//! Use the default fullbright overlay of just 100% lighting
#define FULLBRIGHT_STARLIGHT 2	//! Use the starlight brightness overlay

/// The amount of lumcount on a tile for it to be considered dark (used to determine reading and nyctophobia)
#define LIGHTING_TILE_IS_DARK 0.2

//code assumes higher numbers override lower numbers.
#define LIGHTING_NO_UPDATE 0
#define LIGHTING_VIS_UPDATE 1
#define LIGHTING_CHECK_UPDATE 2
#define LIGHTING_FORCE_UPDATE 3

#define FLASH_LIGHT_DURATION 2
#define FLASH_LIGHT_POWER 3
#define FLASH_LIGHT_RANGE 3.8

/// Uses vis_overlays to leverage caching so that very few new items need to be made for the overlay. For anything that doesn't change outline or opaque area much or at all.
#define EMISSIVE_BLOCK_GENERIC 0
/// Uses a dedicated render_target object to copy the entire appearance in real time to the blocking layer. For things that can change in appearance a lot from the base state, like humans.
#define EMISSIVE_BLOCK_UNIQUE 1
/// Don't block any emissives. Useful for things like, pieces of paper?
#define EMISSIVE_BLOCK_NONE 2

/// A globaly cached version of [EMISSIVE_COLOR] for quick access. Indexed by alpha value
GLOBAL_LIST_INIT(emissive_color, new(256))
/// A set of appearance flags applied to all emissive and emissive blocker overlays.
#define EMISSIVE_APPEARANCE_FLAGS (KEEP_APART|RESET_COLOR|NO_CLIENT_COLOR|PIXEL_SCALE)

/// Colour matrix used to convert items into blockers. The only thing that should be taken into account is the alpha value, and
/// alpha of 1 should be fully black and an alpha of 0 should be black but transparent
/// The reason we aren't working with just white and black here is because white means that the item emits light, and we do not
/// want blockers to start emitting light just because they are transparent. We only want their blocking effect to be reduced.
/// Red = 0
/// Blue = 0
/// Green = 0
/// Alpha = alpha
#define EM_BLOCKER_MATRIX list(0,0,0,0, 0,0,0,0, 0,0,0,0, 0,0,0,1, 0,0,0,0)
/// A globaly cached version of [EM_BLOCKER_MATRIX] for quick access.
GLOBAL_LIST_INIT(em_blocker_matrix, EM_BLOCKER_MATRIX)

/// Parse the hexadecimal color into lumcounts of each perspective.
#define PARSE_LIGHT_COLOR(source) \
do { \
	if (source.light_color) { \
		var/list/color_parts = rgb2num(source.light_color); \
		source.lum_r = color_parts[1] / 255; \
		source.lum_g = color_parts[2] / 255; \
		source.lum_b = color_parts[3] / 255; \
	} else { \
		source.lum_r = 1; \
		source.lum_g = 1; \
		source.lum_b = 1; \
	}; \
} while (FALSE)

GLOBAL_DATUM_INIT(fullbright_overlay, /image, create_fullbright_overlay())

/proc/create_fullbright_overlay()
	var/image/lighting_effect = new()
	lighting_effect.appearance = /obj/effect/fullbright
	return lighting_effect

GLOBAL_DATUM_INIT(starlight_overlay, /image, create_starlight_overlay())

/proc/create_starlight_overlay()
	var/image/lighting_effect = new()
	lighting_effect.appearance = /obj/effect/fullbright/starlight
	return lighting_effect

/// Innate lum source that cannot be removed
#define LUM_SOURCE_INNATE (1 << 4)
/// Luminosity source for glasses
#define LUM_SOURCE_GLASSES (1 << 3)
/// Lum source from mutant bodyparts
#define LUM_SOURCE_MUTANT_BODYPART (1 << 2)
/// Mutually exclusive holy statuses such as cult halos
#define LUM_SOURCE_HOLY (1 << 1)
/// Overlay based luminosity, cleared when overlays are cleared.
/// This is for managed overlays only. You should not be using this.
#define LUM_SOURCE_MANAGED_OVERLAY (1 << 0)

/// Add a luminosity source to a target
#define ADD_LUM_SOURCE(target, em_source) \
UNLINT(target._emissive_count |= em_source);\
if (UNLINT(target._emissive_count == em_source))\
{\
	target.update_luminosity();\
}

/// Remove a luminosity source to a target
#define REMOVE_LUM_SOURCE(target, em_source) \
UNLINT(target._emissive_count &= ~(em_source));\
if (UNLINT(target._emissive_count == 0))\
{\
	target.update_luminosity();\
}
