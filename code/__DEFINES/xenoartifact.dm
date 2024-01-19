//Material defines
///Safe
#define XENOA_BLUESPACE /datum/xenoartifact_material/bluespace
///Mild
#define XENOA_PLASMA /datum/xenoartifact_material/plasma
///Dangerous
#define XENOA_URANIUM /datum/xenoartifact_material/uranium
///Wildcard
#define XENOA_BANANIUM /datum/xenoartifact_material/bananium
///Artificial
#define XENOA_PEARL /datum/xenoartifact_material/pearl
///The gods are about to do something stupid
#define XENOA_DEBUGIUM /datum/xenoartifact_material

//Trait priorities
#define TRAIT_PRIORITY_ACTIVATOR "activator"
#define TRAIT_PRIORITY_MINOR "minor"
#define TRAIT_PRIORITY_MAJOR "major"
#define TRAIT_PRIORITY_MALFUNCTION "malfunction"

///Signal for artifact trigger
#define XENOA_TRIGGER "xenoa_trigger"

///generic starting cooldown timer for triggers
#define XENOA_GENERIC_COOLDOWN 5 SECONDS

//Artifact trait strengths
#define XENOA_TRAIT_STRENGTH_NORMAL 50
#define XENOA_TRAIT_STRENGTH_MILD 75
#define XENOA_TRAIT_STRENGTH_STRONG 100

///trait flags
#define XENOA_BLUESPACE_TRAIT		(1<<0)
#define XENOA_PLASMA_TRAIT			(1<<1)
#define XENOA_URANIUM_TRAIT			(1<<2)
#define XENOA_BANANIUM_TRAIT		(1<<3)
#define XENOA_PEARL_TRAIT		    (1<<4)

///trait cooldowns
#define XENOA_TRAIT_COOLDOWN_EXTRA_SAFE -3 SECONDS
#define XENOA_TRAIT_COOLDOWN_SAFE 3 SECONDS
#define XENOA_TRAIT_COOLDOWN_DANGEROUS 5 SECONDS
#define XENOA_TRAIT_COOLDOWN_GAMER 8 SECONDS

///trait weights, for rarities
#define XENOA_TRAIT_WEIGHT_COMMON 100
#define XENOA_TRAIT_WEIGHT_UNCOMMON 80
#define XENOA_TRAIT_WEIGHT_RARE 50
#define XENOA_TRAIT_WEIGHT_EPIC 10
#define XENOA_TRAIT_WEIGHT_MYTHIC 1

///Label reward and punishment values
#define XENOA_LABEL_REWARD 1.8 //Increases custom price by %80
#define XENOA_LABEL_PUNISHMENT 0.5 //Decreases price by 50%

///Types of artifact activation
#define XENOA_ACTIVATION_TOUCH "XENOA_ACTIVATION_TOUCH"
#define XENOA_ACTIVATION_CONTACT "XENOA_ACTIVATION_CONTACT"

///Common defines for trait hints
#define XENOA_TRAIT_HINT_MATERIAL list("icon" = "eye", "desc" = "This trait can appear in the artifact's material description.")
#define XENOA_TRAIT_HINT_INHAND list("icon" = "search", "desc" = "This trait can be detected by 'feeling' the artifact.")
#define XENOA_TRAIT_HINT_TRIGGER(X) list("icon" = "wrench", "desc" = "This trait can be triggered with a [X].")
#define XENOA_TRAIT_HINT_DETECT(X) list("icon" = "search", "desc" = "This trait can be detected with a [X].")

/*
old content
*/

///Discovery point reward
#define XENOA_DP 350
#define XENOA_SOLD_DP 350
///Reserach point reward (modifer)
#define XENOA_RP 2.5

///Chance to avoid target if wearing bomb suit
#define XENOA_DEFLECT_CHANCE 45

//Xenoartifact signals.
#define XENOA_DEFAULT_SIGNAL "xenoa_default_signal"
#define XENOA_SIGNAL "xenoa_signal"
#define XENOA_CHANGE_PRICE "xenoa_change_price"
