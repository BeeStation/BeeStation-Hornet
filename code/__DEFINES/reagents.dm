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
#define REAGENT_HOLDER_INSTANT_REACT   (1<<7)  // Applied to a reagent holder, all of the reactions in the reagents datum will be instant. Meant to be used for things like smoke effects where reactions aren't meant to occur

/// Is an open container for all intents and purposes.
#define OPENCONTAINER 	(REFILLABLE | DRAINABLE | TRANSPARENT)


// Reagent exposure methods.
/// Used for splashing.
#define TOUCH			(1<<0)
/// Used for ingesting the reagents. Food, drinks, inhaling smoke.
#define INGEST			(1<<1)
/// Used by foams, sprays, and blob attacks.
#define VAPOR			(1<<2)
/// Used by medical patches and gels.
#define PATCH			(1<<3)
/// Used for direct injection of reagents.
#define INJECT			(1<<4)


#define MIMEDRINK_SILENCE_DURATION 30  //ends up being 60 seconds given 1 tick every 2 seconds
#define THRESHOLD_UNHUSK 50 //Health treshold for synthflesh and rezadone to unhusk someone

//used by chem masters and pill presses
#define PILL_STYLE_COUNT 22 //Update this if you add more pill icons or you die
#define RANDOM_PILL_STYLE 22 //Dont change this one though

//Used in holder.dm/equlibrium.dm to set values and volume limits
///stops floating point errors causing issues with checking reagent amounts
#define CHEMICAL_QUANTISATION_LEVEL 0.0001
///The smallest amount of volume allowed - prevents tiny numbers
#define CHEMICAL_VOLUME_MINIMUM 0.001
///Round to this, to prevent extreme decimal magic and to keep reagent volumes in line with perceived values.
#define CHEMICAL_VOLUME_ROUNDING 0.01
///Default pH for reagents datum
#define CHEMICAL_NORMAL_PH 7.000

//reagent bitflags, used for altering how they works
///allows on_mob_dead() if present in a dead body
#define REAGENT_DEAD_PROCESS		(1<<0)
///Do not split the chem at all during processing - ignores all purity effects
#define REAGENT_DONOTSPLIT			(1<<1)
///Doesn't appear on handheld health analyzers.
#define REAGENT_INVISIBLE			(1<<2)
///When inverted, the inverted chem uses the name of the original chem
#define REAGENT_SNEAKYNAME          (1<<3)
///Retains initial volume of chem when splitting for purity effects
#define REAGENT_SPLITRETAINVOL      (1<<4)

//Chemical reaction flags, for determining reaction specialties
///Convert into impure/pure on reaction completion
#define REACTION_CLEAR_IMPURE       (1<<0)
///Convert into inverse on reaction completion when purity is low enough
#define REACTION_CLEAR_INVERSE      (1<<1)
///Clear converted chems retain their purities/inverted purities. Requires 1 or both of the above.
#define REACTION_CLEAR_RETAIN		(1<<2)
///Used to create instant reactions
#define REACTION_INSTANT            (1<<3)
///Used to force reactions to create a specific amount of heat per 1u created. So if thermic_constant = 5, for 1u of reagent produced, the heat will be forced up arbitarily by 5 irresepective of other reagents. If you use this, keep in mind standard thermic_constant values are 100x what it should be with this enabled.
#define REACTION_HEAT_ARBITARY      (1<<4)
///Used to bypass the chem_master transfer block (This is needed for competitive reactions unless you have an end state programmed). More stuff might be added later. When defining this, please add in the comments the associated reactions that it competes with
#define REACTION_COMPETITIVE        (1<<5)

///Used for overheat_temp - This sets the overheat so high it effectively has no overheat temperature.
#define NO_OVERHEAT 99999
///Used to force an equlibrium to end a reaction in reaction_step() (i.e. in a reaction_step() proc return END_REACTION to end it)
#define END_REACTION                "end_reaction"

///if the ph_meter gives a detailed output
#define DETAILED_CHEM_OUTPUT 1
///if the pH meter gives a shorter output
#define SHORTENED_CHEM_OUTPUT 0

#define ENABLE_FLASHING -1

///Tutorial states
#define TUT_NO_BUFFER 50
#define TUT_START 1
#define TUT_HAS_REAGENTS 2
#define TUT_IS_ACTIVE 3
#define TUT_IS_REACTING 4
#define TUT_FAIL 4.5
#define TUT_COMPLETE 5
#define TUT_MISSING 10

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
