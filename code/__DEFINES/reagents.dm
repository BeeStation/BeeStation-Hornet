#define SOLID 1
#define LIQUID 2
#define GAS 3

#define INJECTABLE (1<<0) // Makes it possible to add reagents through droppers and syringes.
#define DRAWABLE (1<<1) // Makes it possible to remove reagents through syringes.

#define REFILLABLE (1<<2) // Makes it possible to add reagents through any reagent container.
#define DRAINABLE (1<<3) // Makes it possible to remove reagents through any reagent container.
#define DUNKABLE (1<<4) // Allows items to be dunked into this container for transfering reagents. Used in conjunction with the dunkable component.

#define TRANSPARENT (1<<5) // Used on containers which you want to be able to see the reagents off.
#define AMOUNT_VISIBLE (1<<6) // For non-transparent containers that still have the general amount of reagents in them visible.
#define NO_REACT (1<<7) // Applied to a reagent holder, the contents will not react with each other.

#define ABSOLUTELY_GRINDABLE   (1<<8)  //! used in 'All-In-One Grinder' that it can grind anything if it has this bitflag

/// Is an open container for all intents and purposes.
#define OPENCONTAINER 	(REFILLABLE | DRAINABLE | TRANSPARENT)


#define TOUCH			1	//! splashing
#define INGEST			2	//! ingestion
#define VAPOR			3	//! foam, spray, blob attack
#define PATCH			4	//! patches
#define INJECT			5	//! injection


//defines passed through to the on_reagent_change proc
#define DEL_REAGENT		1	// reagent deleted (fully cleared)
#define ADD_REAGENT		2	// reagent added
#define REM_REAGENT		3	// reagent removed (may still exist)
#define CLEAR_REAGENTS	4	// all reagents were cleared

#define MIMEDRINK_SILENCE_DURATION 30  //ends up being 60 seconds given 1 tick every 2 seconds
#define THRESHOLD_UNHUSK 50 //Health treshold for synthflesh and rezadone to unhusk someone


//Used in holder.dm/equlibrium.dm to set values and volume limits
///the minimum volume of reagents than can be operated on.
#define CHEMICAL_QUANTISATION_LEVEL 0.0001
/// the default temperature at which chemicals are added to reagent holders at
#define DEFAULT_REAGENT_TEMPERATURE 300

// synthesizable part - can this reagent be synthesized? (for example: odysseus syringe gun)
#define CHEMICAL_NOT_DEFINED   (1<<0)  // identical to CHEMICAL_NOT_SYNTH, but it is good to label when you are not sure which flag you should set on it, or something that shouldn't exist in the game. - i.e) medicine parent type
#define CHEMICAL_NOT_SYNTH     (1<<0)  // no it can't.

// RNG part - having this flag will allow the RNG system to put in.
// if a reagent hasn't a relevant flag, it wouldn't come out from RNG theme - i.e.) maint pill
#define CHEMICAL_BASIC_ELEMENT (1<<1)  // basic chemicals in chemistry - currently used in botany RNG (not yet - refactored for prepration)
#define CHEMICAL_BASIC_DRINK   (1<<2)  // basic chemicals in bartending - currently used in botany RNG (not yet - refactored for prepration)
#define CHEMICAL_RNG_GENERAL   (1<<3)  // it spawns in general stuff - i.e.) vent, abductor gland
#define CHEMICAL_RNG_FUN       (1<<4)  // it spawns in maint pill or something else nasty. This usually has a dramatically interesting list including admin stuff minus some lame ones.
#define CHEMICAL_RNG_BOTANY    (1<<5)  // it spawns in botany strange seeds

// crew objective part - having this flag will allow an objective having a reagent
// Note: to be not disruptive for adding another rng define, goal flags starts at (1<<23) and reversed. (because 23 is max)
#define CHEMICAL_GOAL_CHEMIST_USEFUL_MEDICINE         (1<<23)  // chemist objective - i.e.) make at least 5 units of synthflesh
#define CHEMICAL_GOAL_BOTANIST_HARVEST     (1<<22)  // botanist objective - i.e.) make 12 crops of 10u omnizine
#define CHEMICAL_GOAL_BARTENDER_SERVING    (1<<21) // !NOTE: not implemented, but refactored for preparation - i.e.) serve Bacchus' blessing to 10 crews



/*	<pill sprite size standard>
		Since sprite asset code crops the pill image, you are required to make a pill image within [11,10,21,20] squared area.
		There is a dummy image that you can recognise the size of a cropped pill image in 'pills.dmi'
		The black line counts, so you can use that area for your sprite as well.

	<what are the grey lines in the capsule example?>
		it's a margin that should exist for capsules because it looks bad in TGUI if there's no margin.
 */

// pill shapes - check 'pills.dmi' for the shape
GLOBAL_LIST_INIT(pill_shape_list, list(
		"pill_shape_capsule_purple_pink",
		"pill_shape_capsule_bloodred",
		"pill_shape_capsule_red_whitelined",
		"pill_shape_capsule_orange",
		"pill_shape_capsule_yellow",
		"pill_shape_capsule_green",
		"pill_shape_capsule_skyblue",
		"pill_shape_capsule_indigo",
		"pill_shape_capsule_pink",
		"pill_shape_capsule_white",
		"pill_shape_capsule_white_redlined",
		"pill_shape_capsule_red_orange",
		"pill_shape_capsule_yellow_green",
		"pill_shape_capsule_green_white",
		"pill_shape_capsule_cyan_brown",
		"pill_shape_capsule_purple_yellow",
		"pill_shape_capsule_black_white",
		"pill_shape_capsule_lightgreen_white",
		"pill_shape_tablet_red_lined",
		"pill_shape_tablet_lightred_flat",
		"pill_shape_tablet_orange_flat",
		"pill_shape_tablet_yellow_lined",
		"pill_shape_tablet_green_lined",
		"pill_shape_tablet_lightgreen_flat",
		"pill_shape_tablet_skyblue_lined",
		"pill_shape_tablet_navy_flat",
		"pill_shape_tablet_purple_lined",
		"pill_shape_tablet_pink_lined",
		"pill_shape_tablet_white_lined",
		"pill_shape_tablet_red_yellow_lined",
		"pill_shape_tablet_yellow_purple_lined",
		"pill_shape_tablet_green_purple_lined",
		"pill_shape_tablet_blue_skyblue_lined",
		"pill_shape_tablet_happy",
		"pill_shape_tablet_angry",
		"pill_shape_tablet_sad"))

// using these defines will be consistently manageable
#define PILL_SHAPE_LIST (GLOB.pill_shape_list)
#define PILL_SHAPE_LIST_WITH_DUMMY (GLOB.pill_shape_list+"pill_random_dummy")

GLOBAL_LIST_INIT(patch_shape_list, list(
		"bandaid_small_cross",
		"bandaid_small_blank",
		"bandaid_big_brute",
		"bandaid_big_burn",
		"bandaid_big_both",
		"bandaid_big_blank",))

#define PATCH_SHAPE_LIST (GLOB.patch_shape_list)

//used by chem master
#define CONDIMASTER_STYLE_AUTO "auto"
#define CONDIMASTER_STYLE_FALLBACK "_"

///reagent tags - used to look up reagents for specific effects. Feel free to add to but comment it
/// This reagent does brute effects (BOTH damaging and healing)
#define REACTION_TAG_BRUTE (1<<0)
/// This reagent does burn effects (BOTH damaging and healing)
#define REACTION_TAG_BURN (1<<1)
/// This reagent does toxin effects (BOTH damaging and healing)
#define REACTION_TAG_TOXIN (1<<2)
/// This reagent does oxy effects (BOTH damaging and healing)
#define REACTION_TAG_OXY (1<<3)
/// This reagent does clone effects (BOTH damaging and healing)
#define REACTION_TAG_CLONE (1<<4)
/// This reagent primarily heals, or it's supposed to be used for healing (in the case of c2 - they are healing)
#define REACTION_TAG_HEALING (1<<5)
/// This reagent primarily damages
#define REACTION_TAG_DAMAGING (1<<6)
/// This reagent explodes as a part of it's intended effect (i.e. not overheated/impure)
#define REACTION_TAG_EXPLOSIVE (1<<7)
/// This reagent does things that are unique and special
#define REACTION_TAG_OTHER (1<<8)
/// This reagent affects organs
#define REACTION_TAG_ORGAN (1<<9)
/// This reaction creates a drink reagent
#define REACTION_TAG_DRINK (1<<10)
/// This reaction has something to do with food
#define REACTION_TAG_FOOD (1<<11)
/// This reaction is a slime reaction
#define REACTION_TAG_SLIME (1<<12)
/// This reaction is a drug reaction
#define REACTION_TAG_DRUG (1<<13)
/// This reaction is produces a product that affects reactions
#define REACTION_TAG_CHEMICAL (1<<14)
/// This reaction is produces a product that affects plants
#define REACTION_TAG_PLANT (1<<15)
