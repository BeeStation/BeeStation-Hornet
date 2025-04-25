/*
	These defines are specific to the atom/flags_1 bitmask
*/
#define ALL (~0) //For convenience.
#define NONE 0

//for convenience
#define ENABLE_BITFIELD(variable, flag) (variable |= (flag))
#define DISABLE_BITFIELD(variable, flag) (variable &= ~(flag))
#define CHECK_BITFIELD(variable, flag) (variable & (flag))
#define TOGGLE_BITFIELD(variable, flag) (variable ^= (flag))


//check if all bitflags specified are present
#define CHECK_MULTIPLE_BITFIELDS(flagvar, flags) (((flagvar) & (flags)) == (flags))

/// Currently covers (1<<0) to (1<<22)
GLOBAL_LIST_INIT(bitflags, list(1, 2, 4, 8, 16, 32, 64, 128, 256, 512, 1024, 2048, 4096, 8192, 16384, 32768, 65536, 131072, 262144, 524288, 1048576, 2097152, 4194304))

/* Directions */
///All the cardinal direction bitflags.
#define ALL_CARDINALS (NORTH|SOUTH|EAST|WEST)

// for /datum/var/datum_flags
#define DF_USE_TAG (1<<0)
#define DF_VAR_EDITED (1<<1)
#define DF_ISPROCESSING (1<<2)

//FLAGS BITMASK

/// conducts electricity (iron etc.)
#define CONDUCT_1 (1<<1)
/// For machines and structures that should not break into parts, eg, holodeck stuff
#define NODECONSTRUCT_1 (1<<2)
/// atom queued to SSoverlay
#define OVERLAY_QUEUED_1 (1<<3)
/// item has priority to check when entering or leaving
#define ON_BORDER_1 (1<<4)
/// Prevent clicking things below it on the same turf eg. doors/ fulltile windows
#define PREVENT_CLICK_UNDER_1 (1<<5)
///specifies that this atom is a hologram that isnt real
#define HOLOGRAM_1 (1<<6)
/// grants immunity from being targeted by tesla-style electricity
#define TESLA_IGNORE_1 (1<<7)
///Whether /atom/Initialize() has already run for the object
#define INITIALIZED_1 (1<<8)
/// was this spawned by an admin? used for stat tracking stuff.
#define ADMIN_SPAWNED_1 (1<<9)
/// should not get harmed if this gets caught by an explosion?
#define PREVENT_CONTENTS_EXPLOSION_1 (1<<10)
/// Should this object be unpaintable?
#define UNPAINTABLE_1 (1<<11)
/// Is this atom on top of another atom, and as such has click priority?
#define IS_ONTOP_1 (1<<12)
/// Should we use the initial icon for display? Mostly used by overlay only objects
#define HTML_USE_INITAL_ICON_1 (1<<13)
/// Prevents direct access for anything in the contents of this atom.
#define NO_DIRECT_ACCESS_FROM_CONTENTS_1 (1<<14)
/// Prevents aggregation of the item in the stack panel
#define STAT_UNIQUE_1 (1<<15)
// Whether or not this atom is storing contents for a disassociated storage object
#define HAS_DISASSOCIATED_STORAGE_1 (1<<15)
/// Is this object currently processing in the atmos object list?
#define ATMOS_IS_PROCESSING_1 		(1<<16)

//turf-only flags. These use flags_1 too.
// These exist to cover /turf and /area at the same time
#define NOJAUNT_1					(1<<17)
#define UNUSED_RESERVATION_TURF_1	(1<<18)
#define CAN_BE_DIRTY_1				(1<<19) 	//! If a turf can be made dirty at roundstart. This is also used in areas.
#define NO_LAVA_GEN_1				(1<<20) 	//! Blocks lava rivers being generated on the turf
#define NO_RUINS_1					(1<<21) //! Blocks ruins spawning on the turf

// Update flags for [/atom/proc/update_appearance]
/// Update the atom's name
#define UPDATE_NAME (1<<0)
/// Update the atom's desc
#define UPDATE_DESC (1<<1)
/// Update the atom's icon state
#define UPDATE_ICON_STATE (1<<2)
/// Update the atom's overlays
#define UPDATE_OVERLAYS (1<<3)
/// Update the atom's greyscaling
#define UPDATE_GREYSCALE (1<<4)
/// Update the atom's smoothing. (More accurately, queue it for an update)
#define UPDATE_SMOOTHING (1<<5)
/// Update the atom's icon
#define UPDATE_ICON (UPDATE_ICON_STATE|UPDATE_OVERLAYS)

/// If the thing can reflect light (lasers/energy)
#define RICOCHET_SHINY (1<<0)
/// If the thing can reflect matter (bullets/bomb shrapnel)
#define RICOCHET_HARD (1<<1)

////////////////Area flags\\\\\\\\\\\\\\
/// If it's a valid territory for cult summoning or the CRAB-17 phone to spawn
#define VALID_TERRITORY				(1<<0)
/// If blobs can spawn there and if it counts towards their score.
#define BLOBS_ALLOWED				(1<<1)
/// If mining tunnel generation is allowed in this area
#define CAVES_ALLOWED				(1<<2)
/// If flora are allowed to spawn in this area randomly through tunnel generation
#define FLORA_ALLOWED				(1<<3)
/// If mobs can be spawned by natural random generation
#define MOB_SPAWN_ALLOWED			(1<<4)
/// If megafauna can be spawned by natural random generation
#define MEGAFAUNA_SPAWN_ALLOWED		(1<<5)
/// Hides area from player Teleport function.
#define HIDDEN_AREA					(1<<6)
/// If false, loading multiple maps with this area type will create multiple instances.
#define UNIQUE_AREA					(1<<7)
/// If people are allowed to suicide in it. Mostly for OOC stuff like minigames
#define BLOCK_SUICIDE				(1<<8)
/// Can the Xenobio management console transverse this area by default?
#define XENOBIOLOGY_COMPATIBLE		(1<<9)
/// Are hidden stashes allowed to spawn here?
#define HIDDEN_STASH_LOCATION		(1<<10)
/// Indicates that this area uses an APC from another location (Skips the unit tests for APCs)
#define REMOTE_APC					(1<<11)
/// This area is prevented from having gravity (ie. space, nearstation, or outside solars)
#define NO_GRAVITY 					(1<<12)
/*
	These defines are used specifically with the atom/pass_flags bitmask
	the atom/checkpass() proc uses them (tables will call movable atom checkpass(PASSTABLE) for example)
*/
//flags for pass_flags
#define PASSTABLE		(1<<0)
#define PASSTRANSPARENT	(1<<1)
#define PASSGRILLE		(1<<2)
#define PASSBLOB		(1<<3)
#define PASSMOB			(1<<4)
#define PASSCLOSEDTURF	(1<<5)
/// Let thrown things past us. **ONLY MEANINGFUL ON pass_flags_self!**
#define LETPASSTHROW	(1<<6)
#define PASSMACHINE 	(1<<7)
#define PASSSTRUCTURE 	(1<<8)
#define PASSFLAPS 		(1<<9)
#define PASSDOORS 		(1<<10)
#define PASSANOMALY		(1<<11)
/// Do not intercept click attempts during Adjacent() checks. See [turf/proc/ClickCross]. **ONLY MEANINGFUL ON pass_flags_self!**
#define LETPASSCLICKS	(1<<12)
#define PASSFOAM		(1<<13)

//! ## Movement Types
#define GROUND			(1<<0)
#define FLYING			(1<<1)
#define VENTCRAWLING	(1<<2)
#define FLOATING		(1<<3)
#define PHASING			(1<<4)			//! When moving, will Bump()/Cross() everything, but won't be stopped.
#define THROWN			(1<<5) //! while an atom is being thrown
#define UPSIDE_DOWN 	(1<<6) /// The mob is walking on the ceiling. Or is generally just, upside down.

/// Combination flag for movetypes which, for all intents and purposes, mean the mob is not touching the ground
#define MOVETYPES_NOT_TOUCHING_GROUND (FLYING|FLOATING|UPSIDE_DOWN)

//! ## Fire and Acid stuff, for resistance_flags
#define LAVA_PROOF		(1<<0)
#define FIRE_PROOF		(1<<1) //! 100% immune to fire damage (but not necessarily to lava or heat)
#define FLAMMABLE		(1<<2)
#define ON_FIRE			(1<<3)
#define UNACIDABLE		(1<<4) //! acid can't even appear on it, let alone melt it.
#define ACID_PROOF		(1<<5) //! acid stuck on it doesn't melt it.
#define INDESTRUCTIBLE	(1<<6) //! doesn't take damage
#define FREEZE_PROOF	(1<<7) //! can't be frozen

//tesla_zap
#define TESLA_MACHINE_EXPLOSIVE		(1<<0)
#define TESLA_ALLOW_DUPLICATES		(1<<1)
#define TESLA_OBJ_DAMAGE			(1<<2)
#define TESLA_MOB_DAMAGE			(1<<3)
#define TESLA_MOB_STUN				(1<<4)

#define TESLA_DEFAULT_FLAGS ALL
#define TESLA_ENERGY_PRIMARY_BALL_FLAGS (TESLA_MACHINE_EXPLOSIVE | TESLA_OBJ_DAMAGE | TESLA_MOB_DAMAGE | TESLA_MOB_STUN)
#define TESLA_ENERGY_MINI_BALL_FLAGS (TESLA_OBJ_DAMAGE | TESLA_MOB_DAMAGE | TESLA_MOB_STUN)
#define TESLA_FUSION_FLAGS (TESLA_OBJ_DAMAGE | TESLA_MOB_DAMAGE | TESLA_MOB_STUN)

//EMP protection
#define EMP_PROTECT_SELF (1<<0)
#define EMP_PROTECT_CONTENTS (1<<1)
#define EMP_PROTECT_WIRES (1<<2)

//! ## Mob mobility var flags
#define MOBILITY_MOVE			(1<<0)		//! can move
#define MOBILITY_STAND			(1<<1)		//! can, and is, standing up
#define MOBILITY_PICKUP			(1<<2)		//! can pickup items
#define MOBILITY_USE			(1<<3)		//! can hold and use items
#define MOBILITY_UI				(1<<4)		//! can use interfaces like machinery
#define MOBILITY_STORAGE		(1<<5)		//! can use storage item
#define MOBILITY_PULL			(1<<6)		//! can pull things

#define MOBILITY_FLAGS_DEFAULT (MOBILITY_MOVE | MOBILITY_STAND | MOBILITY_PICKUP | MOBILITY_USE | MOBILITY_UI | MOBILITY_STORAGE | MOBILITY_PULL)

// radiation
#define RAD_PROTECT_CONTENTS (1<<0)
#define RAD_NO_CONTAMINATE (1<<1)

//alternate appearance flags
#define AA_TARGET_SEE_APPEARANCE (1<<0)
#define AA_MATCH_TARGET_OVERLAYS (1<<1)

#define KEEP_TOGETHER_ORIGINAL "keep_together_original"

//setter for KEEP_TOGETHER to allow for multiple sources to set and unset it
#define ADD_KEEP_TOGETHER(x, source)\
	if ((x.appearance_flags & KEEP_TOGETHER) && !HAS_TRAIT(x, TRAIT_KEEP_TOGETHER)) ADD_TRAIT(x, TRAIT_KEEP_TOGETHER, KEEP_TOGETHER_ORIGINAL); \
	ADD_TRAIT(x, TRAIT_KEEP_TOGETHER, source);\
	x.appearance_flags |= KEEP_TOGETHER

#define REMOVE_KEEP_TOGETHER(x, source)\
	REMOVE_TRAIT(x, TRAIT_KEEP_TOGETHER, source);\
	if(HAS_TRAIT_FROM_ONLY(x, TRAIT_KEEP_TOGETHER, KEEP_TOGETHER_ORIGINAL))\
		REMOVE_TRAIT(x, TRAIT_KEEP_TOGETHER, KEEP_TOGETHER_ORIGINAL);\
	else if(!HAS_TRAIT(x, TRAIT_KEEP_TOGETHER))\
		x.appearance_flags &= ~KEEP_TOGETHER

//religious_tool flags
#define RELIGION_TOOL_INVOKE (1<<0)
#define RELIGION_TOOL_SACRIFICE (1<<1)
#define RELIGION_TOOL_SECTSELECT (1<<2)

//dir macros
///Returns true if the dir is diagonal, false otherwise
#define ISDIAGONALDIR(d) (d&(d-1))
///True if the dir is north or south, false therwise
#define NSCOMPONENT(d)   (d&(NORTH|SOUTH))
///True if the dir is east/west, false otherwise
#define EWCOMPONENT(d)   (d&(EAST|WEST))
///Flips the dir for north/south directions
#define NSDIRFLIP(d)     (d^(NORTH|SOUTH))
///Flips the dir for east/west directions
#define EWDIRFLIP(d)     (d^(EAST|WEST))
///Turns the dir by 180 degrees
#define DIRFLIP(d)       turn(d, 180)

// timed_action_flags parameter for `/proc/do_after`
/// Can do the action even if mob moves location
#define IGNORE_USER_LOC_CHANGE (1<<0)
/// Can do the action even if the target moves location
#define IGNORE_TARGET_LOC_CHANGE (1<<1)
/// Can do the action even if the item is no longer being held
#define IGNORE_HELD_ITEM (1<<2)
/// Can do the action even if the mob is incapacitated (ex. handcuffed)
#define IGNORE_INCAPACITATED (1<<3)
