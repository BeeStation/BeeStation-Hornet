
//Light modes
//legacy lighting.
//Slow to update and a bit crap
#define LEGACY_LIGHTING 0			// >> DEPRECIATED; Doesn't work <<
//Fancy lighting
//Uses a lot of CPU updating, however has insanely nice shadows. For static light sources.
#define FANCY_LIGHTING 1
//Quick lighting
//Has no shadows, if you can see the atom that emits the light, you can see the light.
//Because of this you should avoid using it on large light sources.
#define QUICK_LIGHTING 2

#define MINIMUM_USEFUL_LIGHT_RANGE 1.4
#define MINIMUM_LIGHT_SHADOW_RADIUS 2

#define BULLET_FLASH_POWER 100

#define LIGHTING_ICON 'icons/effects/lighting_object.dmi' //! icon used for lighting shading effects
#define LIGHTING_ICON_BIG 'icons/effects/lighting_object_big.dmi' //! icon used for lighting shading effects

#define ALPHA_TO_INTENSITY(alpha) (-(((CLAMP(alpha, 0, 22) - 22) / 6) ** 4) + 255)

//Some defines to generalise colours used in lighting.
//Important note on colors. Colors can end up significantly different from the basic html picture, especially when saturated
#define LIGHT_COLOR_WHITE		"#FFFFFF" //! Full white. rgb(255, 255, 255)
#define LIGHT_COLOR_RED        "#ff3b3b" //! Warm but extremely diluted red. rgb(250, 130, 130)
#define LIGHT_COLOR_GREEN      "#39d139" //! Bright but quickly dissipating neon green. rgb(100, 200, 100)
#define LIGHT_COLOR_BLUE       "#3d7eff" //! Cold, diluted blue. rgb(100, 150, 250)

#define LIGHT_COLOR_BLUEGREEN  "#54e99e" //! Light blueish green. rgb(125, 225, 175)
#define LIGHT_COLOR_PALEBLUE   "#58a2eb" //! A pale blue-ish color. rgb(125, 175, 225)
#define LIGHT_COLOR_CYAN       "#4de7e7" //! Diluted cyan. rgb(125, 225, 225)
#define LIGHT_COLOR_LIGHT_CYAN "#40CEFF" //! More-saturated cyan. rgb(64, 206, 255)
#define LIGHT_COLOR_DARK_BLUE  "#4682fc" //! Saturated blue. rgb(51, 117, 248)
#define LIGHT_COLOR_PINK       "#fc6ffc" //! Diluted, mid-warmth pink. rgb(225, 125, 225)
#define LIGHT_COLOR_YELLOW     "#ebeb67" //! Dimmed yellow, leaning kaki. rgb(225, 225, 125)
#define LIGHT_COLOR_BROWN      "#966432" //! Clear brown, mostly dim. rgb(150, 100, 50)
#define LIGHT_COLOR_ORANGE     "#FA9632" //! Mostly pure orange. rgb(250, 150, 50)
#define LIGHT_COLOR_PURPLE     "#ac4dff" //! Light Purple. rgb(149, 44, 244)
#define LIGHT_COLOR_LAVENDER   "#ab76f0" //! Less-saturated light purple. rgb(155, 81, 255)

#define LIGHT_COLOR_HOLY_MAGIC	"#FFF743" //! slightly desaturated bright yellow.
#define LIGHT_COLOR_BLOOD_MAGIC	"#D00000" //! deep crimson
#define LIGHT_COLOR_CLOCKWORK 	"#BE8700"

//These ones aren't a direct colour like the ones above, because nothing would fit
#define LIGHT_COLOR_FIRE       "#FAA019" //! Warm orange color, leaning strongly towards yellow. rgb(250, 160, 25)
#define LIGHT_COLOR_LAVA       "#C48A18" //! Very warm yellow, leaning slightly towards orange. rgb(196, 138, 24)
#define LIGHT_COLOR_FLARE      "#FA644B" //! Bright, non-saturated red. Leaning slightly towards pink for visibility. rgb(250, 100, 75)
#define LIGHT_COLOR_SLIME_LAMP "#AFC84B" //! Weird color, between yellow and green, very slimy. rgb(175, 200, 75)
#define LIGHT_COLOR_TUNGSTEN   "#FAE1AF" //! Extremely diluted yellow, close to skin color (for some reason). rgb(250, 225, 175)
#define LIGHT_COLOR_HALOGEN    "#F0FAFA" //! Barely visible cyan-ish hue, as the doctor prescribed. rgb(240, 250, 250)

#define LIGHT_RANGE_FIRE		MINIMUM_LIGHT_SHADOW_RADIUS //! How many tiles standard fires glow.

#define LIGHTING_PLANE_ALPHA_VISIBLE 255
#define LIGHTING_PLANE_ALPHA_NV_TRAIT 250
#define LIGHTING_PLANE_ALPHA_MOSTLY_VISIBLE 192
#define LIGHTING_PLANE_ALPHA_MOSTLY_INVISIBLE 128 //! For lighting alpha, small amounts lead to big changes. even at 128 its hard to figure out what is dark and what is light, at 64 you almost can't even tell.
#define LIGHTING_PLANE_ALPHA_INVISIBLE 0

#define FLASH_LIGHT_DURATION 2
#define FLASH_LIGHT_POWER 22	//Maximum power for light mask opacity 255
#define FLASH_LIGHT_RANGE 3.8

/// Uses vis_overlays to leverage caching so that very few new items need to be made for the overlay. For anything that doesn't change outline or opaque area much or at all.
#define EMISSIVE_BLOCK_GENERIC 1
/// Uses a dedicated render_target object to copy the entire appearance in real time to the blocking layer. For things that can change in appearance a lot from the base state, like humans.
#define EMISSIVE_BLOCK_UNIQUE 2

/// Returns the red part of a #RRGGBB hex sequence as number
#define GETREDPART(hexa) hex2num(copytext(hexa, 2, 4))

/// Returns the green part of a #RRGGBB hex sequence as number
#define GETGREENPART(hexa) hex2num(copytext(hexa, 4, 6))

/// Returns the blue part of a #RRGGBB hex sequence as number
#define GETBLUEPART(hexa) hex2num(copytext(hexa, 6, 8))

#define BASE_LIGHTING_STARLIGHT 80
#define BASE_LIGHTING_ALPHA 180

//LEGACY LIGHTING THINGS (Used for hybrid lighting)

//Bay lighting engine shit, not in /code/modules/lighting because BYOND is being shit about it
#define LIGHTING_INTERVAL       5 // frequency, in 1/10ths of a second, of the lighting process
#define LIGHTING_FALLOFF        1 //! type of falloff to use for lighting; 1 for circular, 2 for square
#define LIGHTING_LAMBERTIAN     0 //! use lambertian shading for light sources
#define LIGHTING_HEIGHT         1 //! height off the ground of light sources on the pseudo-z-axis, you should probably leave this alone
#define LIGHTING_ROUND_VALUE    (1 / 64) //! Value used to round lumcounts, values smaller than 1/129 don't matter (if they do, thanks sinking points), greater values will make lighting less precise, but in turn increase performance, VERY SLIGHTLY.
/// If the max of the lighting lumcounts of each spectrum drops below this, disable luminosity on the lighting objects. Set to zero to disable soft lighting. Luminosity changes then work if it's lit at all.
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
	)
//code assumes higher numbers override lower numbers.
#define LIGHTING_NO_UPDATE 0
#define LIGHTING_VIS_UPDATE 1
#define LIGHTING_CHECK_UPDATE 2
#define LIGHTING_FORCE_UPDATE 3
//THERE IS NO UNDYNAMIC LIGHTING MUHAHAHAHAHA!
#define IS_DYNAMIC_LIGHTING(A) 1
/// Parse the hexadecimal color into lumcounts of each perspective.
#define PARSE_LIGHT_COLOR(source) \
do { \
	if (source.light_color) { \
		var/__light_color = source.light_color; \
		source.lum_r = GETREDPART(__light_color) / 255; \
		source.lum_g = GETGREENPART(__light_color) / 255; \
		source.lum_b = GETBLUEPART(__light_color) / 255; \
	} else { \
		source.lum_r = 1; \
		source.lum_g = 1; \
		source.lum_b = 1; \
	}; \
} while (FALSE)

