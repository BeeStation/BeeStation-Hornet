#define SOLID 			1
#define LIQUID			2
#define GAS				3

#define INJECTABLE		(1<<0)	//! Makes it possible to add reagents through droppers and syringes.
#define DRAWABLE		(1<<1)	//! Makes it possible to remove reagents through syringes.

#define REFILLABLE		(1<<2)	//! Makes it possible to add reagents through any reagent container.
#define DRAINABLE		(1<<3)	//! Makes it possible to remove reagents through any reagent container.
#define DUNKABLE 		(1<<4) // Allows items to be dunked into this container for transfering reagents. Used in conjunction with the dunkable component.

#define TRANSPARENT		(1<<5)	//! Used on containers which you want to be able to see the reagents off.
#define AMOUNT_VISIBLE	(1<<6)	//! For non-transparent containers that still have the general amount of reagents in them visible.
#define NO_REACT        (1<<7)  //! Applied to a reagent holder, the contents will not react with each other.

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

//used by chem masters and pill presses
#define PILL_STYLE_COUNT 22 //Update this if you add more pill icons or you die
#define RANDOM_PILL_STYLE 22 //Dont change this one though

//used by chem masters and pill presses
//update this if you add more patch icons
#define PATCH_STYLE_LIST list("bandaid", "bandaid_brute", "bandaid_burn", "bandaid_both") //icon_state list
#define DEFAULT_PATCH_STYLE "bandaid"


//chem grenades defines
/// Grenade is empty
#define GRENADE_EMPTY 1
/// Grenade has a activation trigger
#define GRENADE_WIRED 2
/// Grenade is ready to be finished
#define GRENADE_READY 3

///Minimum requirement for addiction buzz to be met. Addiction code only checks this once every two seconds, so this should generally be low
#define MIN_ADDICTION_REAGENT_AMOUNT 1
///Nicotine requires much less in your system to be happy
#define MIN_NICOTINE_ADDICTION_REAGENT_AMOUNT 0.01
#define MAX_ADDICTION_POINTS 1000

///Addiction start/ends
#define WITHDRAWAL_STAGE1_START_CYCLE 60
#define WITHDRAWAL_STAGE1_END_CYCLE 120
#define WITHDRAWAL_STAGE2_START_CYCLE 121
#define WITHDRAWAL_STAGE2_END_CYCLE 180
#define WITHDRAWAL_STAGE3_START_CYCLE 181

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
/// This reagent's reaction is dangerous to create (i.e. explodes if you fail it)
#define REACTION_TAG_DANGEROUS (1<<9)
/// This reagent's reaction is easy
#define REACTION_TAG_EASY (1<<10)
/// This reagent's reaction is difficult/involved
#define REACTION_TAG_MODERATE (1<<11)
/// This reagent's reaction is hard
#define REACTION_TAG_HARD (1<<12)
/// This reagent affects organs
#define REACTION_TAG_ORGAN (1<<13)
/// This reaction creates a drink reagent
#define REACTION_TAG_DRINK (1<<14)
/// This reaction has something to do with food
#define REACTION_TAG_FOOD (1<<15)
/// This reaction is a slime reaction
#define REACTION_TAG_SLIME (1<<16)
/// This reaction is a drug reaction
#define REACTION_TAG_DRUG (1<<17)
/// This reaction is a unique reaction
#define REACTION_TAG_UNIQUE (1<<18)
/// This reaction is produces a product that affects reactions
#define REACTION_TAG_CHEMICAL (1<<19)
/// This reaction is produces a product that affects plants
#define REACTION_TAG_PLANT (1<<20)
/// This reaction is produces a product that affects plants
#define REACTION_TAG_COMPETITIVE (1<<21)


///Used for overheat_temp - This sets the overheat so high it effectively has no overheat temperature.
#define NO_OVERHEAT 99999
