/// Is the material from an ore? currently unused but exists atm for categorizations sake
#define MAT_CATEGORY_ORE "ore capable"

/// Hard materials, such as iron or metal
#define MAT_CATEGORY_RIGID "rigid material"

///Use this flag on TRUE if you want the basic recipes
#define MAT_CATEGORY_BASE_RECIPES "basic recipes"

/// Used to make a material initialize at roundstart.
#define MATERIAL_INIT_MAPLOAD	(1<<0)

// Breakdown flags used when decomposing alloys. Should be expanded upon and diversified once someone gets around to reworking recycling.
/// Can reduce an alloy into its component materials.
#define BREAKDOWN_ALLOYS				(1<<0)
/// Breakdown flags used by techfabs and circuit printers.
#define BREAKDOWN_FLAGS_LATHE			(BREAKDOWN_ALLOYS)
/// Breakdown flags used by the ORM.
#define BREAKDOWN_FLAGS_ORM				(BREAKDOWN_ALLOYS)
/// Breakdown flags used by the recycler.
#define BREAKDOWN_FLAGS_RECYCLER		(BREAKDOWN_ALLOYS)
/// Breakdown flags used by the sheetifier.
#define BREAKDOWN_FLAGS_SHEETIFIER		(BREAKDOWN_ALLOYS)
/// Breakdown flags used by the ore processor.
#define BREAKDOWN_FLAGS_ORE_PROCESSOR	(BREAKDOWN_ALLOYS)
/// Breakdown flags used by the drone dispenser.
#define BREAKDOWN_FLAGS_DRONE_DISPENSER	(BREAKDOWN_ALLOYS)

/// Whether a material's mechanical effects should apply to the atom. This is necessary for other flags to work.
#define MATERIAL_EFFECTS (1<<0)
/// Applies the material color to the atom's color. Deprecated, use MATERIAL_GREYSCALE instead
#define MATERIAL_COLOR (1<<1)
/// Whether a prefix describing the material should be added to the name
#define MATERIAL_ADD_PREFIX (1<<2)
/// Whether a material should affect the stats of the atom
#define MATERIAL_AFFECT_STATISTICS (1<<3)
/// Applies the material greyscale color to the atom's greyscale color.
#define MATERIAL_GREYSCALE (1<<4)

#define MATERIAL_SOURCE(mat) "[mat.name]_material"

// Slowdown values.
/// The slowdown value of one [MINERAL_MATERIAL_AMOUNT] of plasteel.
#define MATERIAL_SLOWDOWN_PLASTEEL		(0.05)
/// The slowdown value of one [MINERAL_MATERIAL_AMOUNT] of alien alloy.
#define MATERIAL_SLOWDOWN_ALIEN_ALLOY	(0.1)

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
