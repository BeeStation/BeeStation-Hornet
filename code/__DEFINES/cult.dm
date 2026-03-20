//! ### rune colors, for easy reference
#define RUNE_COLOR_MEDIUMRED "#C80000"
#define RUNE_COLOR_BURNTORANGE "#CC5500"
#define RUNE_COLOR_EMP "#4D94FF"

//blood magic
/// The maximum number of cult spell slots each cultist is allowed to scribe at once.
#define ENHANCED_BLOODCHARGE 5
#define MAX_BLOODCHARGE 4
#define RUNELESS_MAX_BLOODCHARGE 1
#define CULT_RISEN 0.2 //! percent before rise
#define CULT_ASCENDENT 0.4 //! percent before ascend
#define BLOOD_HALBERD_COST 150
#define BLOOD_BARRAGE_COST 300
#define BLOOD_BEAM_COST 500
#define IRON_TO_CONSTRUCT_SHELL_CONVERSION 50
//screen locations
#define DEFAULT_BLOODSPELLS "6:-29,4:+15"
// misc
#define SOULS_TO_REVIVE 3
#define BLOODCULT_EYE COLOR_RED

//soulstone & construct themes
#define THEME_CULT "cult"
#define THEME_WIZARD "wizard"
#define THEME_HOLY "holy"

/// Defines for cult item_dispensers.
#define PREVIEW_IMAGE "preview"
#define OUTPUT_ITEMS "output"
#define RADIAL_DESC "radial_desc"

///how many sacrifices we have used, cultists get 1 free revive at the start
GLOBAL_VAR_INIT(sacrifices_used, -SOULS_TO_REVIVE)

/// list of weakrefs to mobs OR minds that have been sacrificed
GLOBAL_LIST(sacrificed)

///how many times can the shuttle be cursed?
#define MAX_SHUTTLE_CURSES 3
