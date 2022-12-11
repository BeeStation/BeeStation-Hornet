#define SOLID 			1
#define LIQUID			2
#define GAS				3

#define INJECTABLE		(1<<0)	//! Makes it possible to add reagents through droppers and syringes.
#define DRAWABLE		(1<<1)	//! Makes it possible to remove reagents through syringes.

#define REFILLABLE		(1<<2)	//! Makes it possible to add reagents through any reagent container.
#define DRAINABLE		(1<<3)	//! Makes it possible to remove reagents through any reagent container.

#define TRANSPARENT		(1<<4)	//! Used on containers which you want to be able to see the reagents off.
#define AMOUNT_VISIBLE	(1<<5)	//! For non-transparent containers that still have the general amount of reagents in them visible.
#define NO_REACT        (1<<6)  //! Applied to a reagent holder, the contents will not react with each other.

#define ABSOLUTELY_GRINDABLE   (1<<7)  //! used in 'All-In-One Grinder' that it can grind anything if it has this bitflag

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
#define CHEMICAL_GOAL_CHEMIST_DRUG         (1<<23)  // chemist objective - i.e.) make 24 pills of 12u meth
#define CHEMICAL_GOAL_CHEMIST_BLOODSTREAM  (1<<22)  // chemist objective - i.e.) eat meth in your bloodstream
#define CHEMICAL_GOAL_BOTANIST_HARVEST     (1<<21)  // botanist objective - i.e.) make 12 crops of 10u omnizine
#define CHEMICAL_GOAL_BARTENDER_SERVING    (1<<20) // !NOTE: not implemented, but refactored for preparation - i.e.) serve Bacchus' blessing to 10 crews
