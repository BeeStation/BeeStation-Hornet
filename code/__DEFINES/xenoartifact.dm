//Material defines
///Safe
#define XENOA_BLUESPACE /datum/component/xenoartifact_material
///Mild
#define XENOA_PLASMA /datum/component/xenoartifact_material
///Dangerous
#define XENOA_URANIUM /datum/component/xenoartifact_material
///Wildcard
#define XENOA_BANANIUM /datum/component/xenoartifact_material
///The gods are about to do something stupid
#define XENOA_DEBUGIUM /datum/component/xenoartifact_material

//Trait priorities
#define TRAIT_PRIORITY_ACTIVATOR "activator"
#define TRAIT_PRIORITY_MINOR "minor"
#define TRAIT_PRIORITY_MAJOR "major"
#define TRAIT_PRIORITY_MALFUNCTION "malfunction"

///Signal for artifact trigger
#define XENOA_TRIGGER "xenoa_trigger"

///generic starting cooldown timer for triggers
#define XENOA_GENERIC_COOLDOWN 8 SECONDS

//Artifact trait strengths
#define XENOA_TRAIT_STRENGTH_NORMAL 50
#define XENOA_TRAIT_STRENGTH_MILD 75
#define XENOA_TRAIT_STRENGTH_STRONG 100

///trait flags
#define BLUESPACE_TRAIT			(1<<0)
#define PLASMA_TRAIT			(1<<1)
#define URANIUM_TRAIT			(1<<2)
#define BANANIUM_TRAIT			(1<<3)

/*
old content
*/

//Also not materials but also related
///Process type on burn
#define PROCESS_TYPE_LIT "is_lit"
///Process type on ticking
#define PROCESS_TYPE_TICK "is_tick"

///Discovery point reward
#define XENOA_DP 350
#define XENOA_SOLD_DP 350
///Reserach point reward (modifer)
#define XENOA_RP 2.5

///Max vendors / buyers in each catergory
#define XENOA_MAX_VENDORS 8

//Specific trait defines
///Bear limit at once
#define XENOA_MAX_BEARS 3
///Max targets on expansive
#define XENOA_MAX_TARGETS 6
///Tick chance to untick
#define XENOA_TICK_CANCEL_PROB 13
///Max amount of evil clones at once
#define XENOA_MAX_CLONES 5

///Chance to avoid target if wearing bomb suit
#define XENOA_DEFLECT_CHANCE 45

//Xenoartifact signals.
#define XENOA_DEFAULT_SIGNAL "xenoa_default_signal"
#define XENOA_SIGNAL "xenoa_signal"
#define XENOA_CHANGE_PRICE "xenoa_change_price"
