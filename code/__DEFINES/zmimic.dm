#define TURF_IS_MIMICKING(T) (isturf(T) && (T:z_flags & Z_MIMIC_BELOW))

#define CHECK_OO_EXISTENCE(OO) if (OO && !MOVABLE_IS_ON_ZTURF(OO) && !OO:destruction_timer) { OO:destruction_timer = QDEL_IN(OO, 10 SECONDS); }
#define UPDATE_OO_IF_PRESENT CHECK_OO_EXISTENCE(src:bound_overlay); if (src:bound_overlay) { update_above(); }

// These aren't intended to be used anywhere else, they just can't be undef'd because DM is dum.
#define ZM_INTERNAL_SCAN_LOOKAHEAD(M,VTR,F) ((get_step(M, M:dir)?:VTR & F) || (get_step(M, turn(M:dir, 180))?:VTR & F))
#define ZM_INTERNAL_SCAN_LOOKBESIDE(M,VTR,F) ((get_step(M, turn(M:dir, 90))?:VTR & F) || (get_step(M, turn(M:dir, -90))?:VTR & F))

/// Is this movable visible from a turf that is mimicking below? Note: this does not necessarily mean *directly* below.
#define MOVABLE_IS_BELOW_ZTURF(M) (\
	isturf(loc) && (TURF_IS_MIMICKING(loc:above) \
	|| ((M:zmm_flags & ZMM_LOOKAHEAD) && ZM_INTERNAL_SCAN_LOOKAHEAD(M, above?:z_flags, Z_MIMIC_BELOW))  \
	|| ((M:zmm_flags & ZMM_LOOKBESIDE) && ZM_INTERNAL_SCAN_LOOKBESIDE(M, above?:z_flags, Z_MIMIC_BELOW))) \
)
/// Is this movable located on a turf that is mimicking below? Note: this does not necessarily mean *directly* on.
#define MOVABLE_IS_ON_ZTURF(M) (\
	isturf(loc) && (TURF_IS_MIMICKING(loc:above) \
	|| ((M:zmm_flags & ZMM_LOOKAHEAD) && ZM_INTERNAL_SCAN_LOOKAHEAD(M, z_flags, Z_MIMIC_BELOW)) \
	|| ((M:zmm_flags & ZMM_LOOKBESIDE) && ZM_INTERNAL_SCAN_LOOKBESIDE(M, z_flags, Z_MIMIC_BELOW))) \
)


// Z-level flags, used by zmove and Z-Mimic.

#define Z_BLOCK_IN_UP      (1 << 0)	//! Allows movement IN from higher Z levels
#define Z_BLOCK_IN_DOWN    (1 << 1)	//! Allows movement IN from lower z levels
#define Z_BLOCK_OUT_UP     (1 << 2)	//! Allows movement OUT to higher Z levels
#define Z_BLOCK_OUT_DOWN   (1 << 3)	//! Allows movement OUT to LOWER z levels

#define Z_MIMIC_BELOW      (1 << 4)	//! Should this turf mimic the below turf?
#define Z_MIMIC_OVERWRITE  (1 << 5)	//! If this turf is mimicking, overwrite its appearance instead of using a mimic object. This is faster, but means the turf cannot have its own appearance.
#define Z_MIMIC_NO_OCCLUDE (1 << 6)	//! If we're a non-OVERWRITE z-turf, allow clickthrough of this turf.
#define Z_MIMIC_BASETURF   (1 << 7)	//! Fake-copy baseturf instead of below turf.

GLOBAL_LIST_INIT(z_defines, list(
	"Z_BLOCK_IN_UP",
	"Z_BLOCK_IN_DOWN",
	"Z_BLOCK_OUT_UP",
	"Z_BLOCK_OUT_DOWN",

	"Z_MIMIC_BELOW",
	"Z_MIMIC_OVERWRITE",
	"Z_MIMIC_NO_OCCLUDE",
	"Z_MIMIC_BASETURF"
))

// Z-Mimic movable flags. This is not prefixed with ZM_* to avoid confusion with other codebases that use that prefix for the above flags.

#define ZMM_IGNORE          (1 << 0)	//! Do not copy this movable. Atoms with INVISIBILITY_ABSTRACT implicitly do not copy.
#define ZMM_MANGLE_PLANES   (1 << 1)	//! Check this movable's overlays/underlays for explicit plane use and mangle for compatibility with Z-Mimic. If you're using emissive overlays, you probably should be using this flag. Expensive, only use if necessary.
#define ZMM_LOOKAHEAD       (1 << 2)	//! Look one turf ahead and one turf back when considering z-turfs that might be seeing this atom. Respects dir. Cheap, but not free.
#define ZMM_LOOKBESIDE      (1 << 3)	//! Look one turf to the left and right when considering z-turfs that might be seeing this atom. Respects dir. Cheap, but not free.
#define ZMM_AUTOMANGLE      (1 << 4)	//! Behaves the same as ZMM_MANGLE_PLANES, but is automatically applied by SSoverlays. Do not manually use.

// convenience flags
#define ZMM_WIDE_LOAD (ZMM_LOOKAHEAD | ZMM_LOOKBESIDE)	//! Atom is big and needs to scan one extra turf in both X and Y. This only extends the range by one turf. Cheap, but not free.

/*
On ZMM_AUTOMANGLE:
	It's separate from ZMM_MANGLE_PLANES so SSoverlays doesn't disable mangling on a manually flagged atom.
*/
