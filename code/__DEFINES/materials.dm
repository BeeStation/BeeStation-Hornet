/// Is the material from an ore? currently unused but exists atm for categorizations sake
#define MAT_CATEGORY_ORE "ore capable"

/// Hard materials, such as iron or metal
#define MAT_CATEGORY_RIGID "rigid material"

///Use this flag on TRUE if you want the basic recipes
#define MAT_CATEGORY_BASE_RECIPES "basic recipes"

//Use this flag on TRUE if you want metallic basemat structures(metal-like)
#define MAT_CATEGORY_METALLIC_RECIPES "metallic recipes"
//Use this flag on True if you want silicate basemat structures(glass-like)
#define MAT_CATEGORY_SILICATE_RECIPES "silicate recipes"

/// Flag for atoms, this flag ensures it isn't re-colored by materials. Useful for snowflake icons such as default toolboxes.
#define MATERIAL_COLOR (1<<0)
/// Whether a prefix describing the material should be added to the name
#define MATERIAL_ADD_PREFIX (1<<1)
/// Whether a material's mechanical effects should apply to the atom
#define MATERIAL_NO_EFFECTS (1<<2)
/// Whether a material should affect the stats of the atom
#define MATERIAL_AFFECT_STATISTICS (1<<3)
/// Applies the material greyscale color to the atom's greyscale color.
#define MATERIAL_GREYSCALE (1<<4)

/// Create standardized stack sizes.

#define STACKSIZE_MACRO(Path)\
##Path/fifty{\
	amount = 50; \
} \
##Path/twenty{\
	amount = 20; \
} \
##Path/ten{\
	amount = 10; \
} \
##Path/five{\
	amount = 5; \
} \
