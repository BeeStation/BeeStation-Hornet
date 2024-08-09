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

//pH and impurity shit, not desirable for us, but just for compatibility reasons if we ever want to pick those prs apart for their optimizations (3/20/2023)
/*
#define REAGENT_HOLDER_INSTANT_REACT (1<<9)  // Applied to a reagent holder, all of the reactions in the reagents datum will be instant. Meant to be used for things like smoke effects where reactions aren't meant to occur
///If the holder is "alive" (i.e. mobs and organs) - If this flag is applied to a holder it will cause reagents to split upon addition to the object
#define REAGENT_HOLDER_ALIVE (1<<10)
*/

/*
///If the holder a sealed container - Used if you don't want reagent contents boiling out (plasma, specifically, in which case it only bursts out when at ignition temperatures)
#define SEALED_CONTAINER (1<<11)
*/

// Is an open container for all intents and purposes.
#define OPENCONTAINER (REFILLABLE | DRAINABLE | TRANSPARENT)

/// Used for splashing.
#define TOUCH 1
/// Used for ingesting the reagents. Food, drinks, inhaling smoke.
#define INGEST 2
/// Used by foams, sprays, and blob attacks.
#define VAPOR 3
/// Used by medical patches
#define PATCH 4
/// Used for direct injection of reagents.
#define INJECT 5


//defines passed through to the on_reagent_change proc
#define DEL_REAGENT 1 // reagent deleted (fully cleared)
#define ADD_REAGENT 2 // reagent added
#define REM_REAGENT 3 // reagent removed (may still exist)
#define CLEAR_REAGENTS 4 // all reagents were cleared

#define MIMEDRINK_SILENCE_DURATION 30 //ends up being 60 seconds given 1 tick every 2 seconds
#define THRESHOLD_UNHUSK 50 //Health treshold for synthflesh and rezadone to unhusk someone

///Minimum requirement for addiction buzz to be met. Addiction code only checks this once every two seconds, so this should generally be low
#define MIN_ADDICTION_REAGENT_AMOUNT 1
///Nicotine requires much less in your system to be happy
#define MIN_NICOTINE_ADDICTION_REAGENT_AMOUNT 0.01
#define MAX_ADDICTION_POINTS 1000

///Addiction start/ends
#define WITHDRAWAL_STAGE1_START_CYCLE 61
#define WITHDRAWAL_STAGE1_END_CYCLE 120
#define WITHDRAWAL_STAGE2_START_CYCLE 121
#define WITHDRAWAL_STAGE2_END_CYCLE 180
#define WITHDRAWAL_STAGE3_START_CYCLE 181

// synthesizable part - can this reagent be synthesized? (for example: odysseus syringe gun)
#define CHEMICAL_NOT_DEFINED (1<<0)  // identical to CHEMICAL_NOT_SYNTH, but it is good to label when you are not sure which flag you should set on it, or something that shouldn't exist in the game. - i.e) medicine parent type
#define CHEMICAL_NOT_SYNTH (1<<0)  // no it can't.

// RNG part - having this flag will allow the RNG system to put in.
// if a reagent hasn't a relevant flag, it wouldn't come out from RNG theme - i.e.) maint pill
#define CHEMICAL_BASIC_ELEMENT (1<<1)  // basic chemicals in chemistry - currently used in botany RNG (not yet - refactored for prepration)
#define CHEMICAL_BASIC_DRINK (1<<2)  // basic chemicals in bartending - currently used in botany RNG (not yet - refactored for prepration)
#define CHEMICAL_RNG_GENERAL (1<<3)  // it spawns in general stuff - i.e.) vent, abductor gland
#define CHEMICAL_RNG_FUN (1<<4)  // it spawns in maint pill or something else nasty. This usually has a dramatically interesting list including admin stuff minus some lame ones.
#define CHEMICAL_RNG_BOTANY (1<<5)  // it spawns in botany strange seeds

// crew objective part - having this flag will allow an objective having a reagent
// Note: to be not disruptive for adding another rng define, goal flags starts at (1<<23) and reversed. (because 23 is max)
#define CHEMICAL_GOAL_CHEMIST_USEFUL_MEDICINE (1<<23)  // chemist objective - i.e.) make at least 5 units of synthflesh
#define CHEMICAL_GOAL_BOTANIST_HARVEST (1<<22)  // botanist objective - i.e.) make 12 crops of 10u omnizine
#define CHEMICAL_GOAL_BARTENDER_SERVING (1<<21) // !NOTE: not implemented, but refactored for preparation - i.e.) serve Bacchus' blessing to 10 crews



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
