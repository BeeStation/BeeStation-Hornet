//Bloody shoes/footprints
/// Minimum alpha of footprints
#define BLOODY_FOOTPRINT_BASE_ALPHA 20
/// How much blood a regular blood splatter contains
#define BLOOD_AMOUNT_PER_DECAL 50
/// How much blood an item can have stuck on it
#define BLOOD_ITEM_MAX 200
/// How much blood a blood decal can contain
#define BLOOD_POOL_MAX 300
/// How much blood a footprint need to at least contain
#define BLOOD_FOOTPRINTS_MIN 5
/// Bloodiness -> reagent units multiplier
#define BLOOD_TO_UNITS_MULTIPLIER 0.1

// Bloodtype defines
#define BLOOD_TYPE_A_MINUS "A-"
#define BLOOD_TYPE_A_PLUS "A+"
#define BLOOD_TYPE_B_MINUS "B-"
#define BLOOD_TYPE_B_PLUS "B+"
#define BLOOD_TYPE_AB_MINUS "AB-"
#define BLOOD_TYPE_AB_PLUS "AB+"
#define BLOOD_TYPE_O_MINUS "O-"
#define BLOOD_TYPE_O_PLUS "O+"
#define BLOOD_TYPE_UNIVERSAL "U"
#define BLOOD_TYPE_LIZARD "L"
#define BLOOD_TYPE_ANIMAL "Y-"
#define BLOOD_TYPE_ETHEREAL "LE"
#define BLOOD_TYPE_TOX "TOX"
#define BLOOD_TYPE_OIL "Oil"
#define BLOOD_TYPE_SYNTHETIC "Coolant"
#define BLOOD_TYPE_MEAT "MT-"
#define BLOOD_TYPE_CLOWN "C"
#define BLOOD_TYPE_XENO "X*"
#define BLOOD_TYPE_CHLOROPHYLL "CHL"
#define BLOOD_TYPE_SPORE "SPR"
#define BLOOD_TYPE_SNAIL "S"

// Blood exposure behavior flag defines
/// Add our DNA to turfs/mobs/items, does not correlate with adding decals/overlays
/// mob/turf/item flags will add DNA when triggered even if this flag is false
#define BLOOD_ADD_DNA (1<<0)
/// Cover the entire mob in *visible* blood
#define BLOOD_COVER_MOBS (1<<1)
/// Create blood splashes and trails on floors, does not affect gibs creation
#define BLOOD_COVER_TURFS (1<<2)
/// Cover items in ourselves
#define BLOOD_COVER_ITEMS (1<<3)
/// Usually you want all COVER flags together or none at all
#define BLOOD_COVER_ALL (BLOOD_COVER_MOBS | BLOOD_COVER_TURFS | BLOOD_COVER_ITEMS)
/// Transfer blood immunities and viruses to exposed mobs
#define BLOOD_TRANSFER_VIRAL_DATA (1<<4)

// Bleed check results
/// We cannot bleed (here, or in general) at all
#define BLEED_NONE 0
/// We cannot make a splatter, but we can add our DNA
#define BLEED_ADD_DNA 1
/// We can bleed just fine
#define BLEED_SPLATTER 2
