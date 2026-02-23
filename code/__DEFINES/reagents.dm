#define SOLID 1
#define LIQUID 2
#define GAS 3

/// Makes it possible to add reagents through droppers and syringes.
#define INJECTABLE (1<<0)
/// Makes it possible to remove reagents through syringes.
#define DRAWABLE (1<<1)

/// Makes it possible to add reagents through any reagent container.
#define REFILLABLE (1<<2)
/// Makes it possible to remove reagents through any reagent container.
#define DRAINABLE (1<<3)
/// Allows items to be dunked into this container for transfering reagents. Used in conjunction with the dunkable component.
#define DUNKABLE (1<<4)

// Used on containers which you want to be able to see the reagents off.
#define TRANSPARENT (1<<5)
// For non-transparent containers that still have the general amount of reagents in them visible.
#define AMOUNT_VISIBLE (1<<6)
// Applied to a reagent holder, the contents will not react with each other.
#define NO_REACT (1<<7)

/// Used in 'All-In-One Grinder' that it can grind anything if it has this bitflag
#define ABSOLUTELY_GRINDABLE (1<<8)

/// Is an open container for all intents and purposes.
#define OPENCONTAINER (REFILLABLE | DRAINABLE | TRANSPARENT)

/// Splashing
#define TOUCH 1
/// Ingestion
#define INGEST 2
/// Foam, spray, blob attack
#define VAPOR 3
/// Patches
#define PATCH 4
/// Syringes
#define INJECT 5

/// Reagent effect multiplier - adjusts all effects according to metabolism rate
#define REAGENTS_EFFECT_MULTIPLIER (REAGENTS_METABOLISM / 0.4)
/// Shorthand for the above define for ease of use in equations and the like
#define REM REAGENTS_EFFECT_MULTIPLIER
/// How much of a reagent is converted to metabolites if one is defined
#define METABOLITE_RATE 0.5
/// The maximum amount of a given metabolite someone can have at a time
#define MAX_METABOLITES 15
/// Ranges from 1 to 5 depending on level of metabolites
#define METABOLITE_PENALTY(path) clamp(affected_mob.reagents.get_reagent_amount(path)/2.5, 1, 5)

/// When returned by on_mob_life(), on_mob_dead(), overdose_start() or overdose_processed(), will cause the mob to updatehealth() afterwards
#define UPDATE_MOB_HEALTH 1

/// Defines passed through to the on_reagent_change proc
#define DEL_REAGENT 1 // reagent deleted (fully cleared)
#define ADD_REAGENT 2 // reagent added
#define REM_REAGENT 3 // reagent removed (may still exist)
#define CLEAR_REAGENTS 4 // all reagents were cleared

// How long do mime drinks silence the drinker (if they are a mime)?
#define MIMEDRINK_SILENCE_DURATION 1 MINUTES
#define THRESHOLD_UNHUSK 50 //Health treshold for synthflesh and rezadone to unhusk someone

/// Greater numbers mean that less alcohol has greater intoxication potential
#define ALCOHOL_THRESHOLD_MODIFIER 1
/// The rate at which alcohol affects you
#define ALCOHOL_RATE 0.005
/// The exponent applied to boozepwr to make higher volume alcohol at least a little bit damaging to the liver
#define ALCOHOL_EXPONENT 1.6

/// Reaction hint for explosions
#define REACTION_HINT_EXPLOSION_OTHER "explosion"
/// A radius table showing the radius at 10, 50 and 100, 200 and 500 units of the reaction
#define REACTION_HINT_RADIUS_TABLE "explosion_radius"
/// Reaction safety hint
#define REACTION_HINT_SAFETY "safety"

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

//Used in holder.dm/equlibrium.dm to set values and volume limits
///the minimum volume of reagents than can be operated on.
#define CHEMICAL_QUANTISATION_LEVEL 0.0001
/// the default temperature at which chemicals are added to reagent holders at
#define DEFAULT_REAGENT_TEMPERATURE 300

/// If present, when metabolizing out of a mob, we divide by the mob's metabolism rather than multiply.
/// Without this flag: Higher metabolism means the reagent exits the system faster.
/// With this flag: Higher metabolism means the reagent exits the system slower.
#define REAGENT_REVERSE_METABOLISM (1<<10)
/// If present, this reagent will not be affected by the mob's metabolism at all, meaning it exits at a fixed rate for all mobs.
/// Supercedes [REAGENT_REVERSE_METABOLISM].
#define REAGENT_UNAFFECTED_BY_METABOLISM (1<<11)

// synthesizable part - can this reagent be synthesized? (for example: odysseus syringe gun)
#define CHEMICAL_NOT_DEFINED   (1<<0)  // identical to CHEMICAL_NOT_SYNTH, but it is good to label when you are not sure which flag you should set on it, or something that shouldn't exist in the game. - i.e) medicine parent type
#define CHEMICAL_NOT_SYNTH     (1<<0)  // no it can't.

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
