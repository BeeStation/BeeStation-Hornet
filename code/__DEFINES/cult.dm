//! ### rune colors, for easy reference
#define RUNE_COLOR_MEDIUMRED "#C80000"
#define RUNE_COLOR_BURNTORANGE "#CC5500"
#define RUNE_COLOR_EMP "#4D94FF"

//! ## blood magic
#define MAX_BLOODCHARGE 4
#define RUNELESS_MAX_BLOODCHARGE 1
#define CULT_RISEN 0.2 //! percent before rise
#define CULT_ASCENDENT 0.4 //! percent before ascend
#define BLOOD_SPEAR_COST 150
#define BLOOD_BARRAGE_COST 300
#define BLOOD_BEAM_COST 500
#define IRON_TO_CONSTRUCT_SHELL_CONVERSION 50
// misc
#define SOULS_TO_REVIVE 3
#define BLOODCULT_EYE COLOR_RED

//soulstone & construct themes
#define THEME_CULT "cult"
#define THEME_WIZARD "wizard"
#define THEME_HOLY "holy"

///how many sacrifices we have used, cultists get 1 free revive at the start
GLOBAL_VAR_INIT(sacrifices_used, -SOULS_TO_REVIVE)

/// list of weakrefs to mobs OR minds that have been sacrificed
GLOBAL_LIST(sacrificed)
