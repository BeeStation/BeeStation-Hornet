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

//Trait incompatabilities
#define TRAIT_INCOMPATIBLE_ITEM (1<<0)
#define TRAIT_INCOMPATIBLE_MOB (1<<1)
#define TRAIT_INCOMPATIBLE_STRUCTURE (1<<2)

///Signal for artifact trigger
#define COMSIG_XENOA_TRIGGER "COMSIG_XENOA_TRIGGER"
///Signal for artifact calcified
#define COMSIG_XENOA_CALCIFIED "COMSIG_XENOA_CALCIFIED"

///Signal for SS needing new mainc onsole
#define COMSIG_XENOA_REQUEST_NEW_CONSOLE "COMSIG_XENOA_REQUEST_NEW_CONSOLE"

///generic starting cooldown timer for triggers
#define XENOA_GENERIC_COOLDOWN 5 SECONDS

//Artifact trait strengths
#define XENOA_TRAIT_STRENGTH_NORMAL 50
#define XENOA_TRAIT_STRENGTH_MILD 75
#define XENOA_TRAIT_STRENGTH_STRONG 100

///trait flags
#define XENOA_BLUESPACE_TRAIT	(1<<0) //Github's webview fucks these up, but they look fine in the editor
#define XENOA_PLASMA_TRAIT		(1<<1)
#define XENOA_URANIUM_TRAIT		(1<<2)
#define XENOA_BANANIUM_TRAIT	(1<<3)
#define XENOA_PEARL_TRAIT		(1<<4)
#define XENOA_MISC_TRAIT		(1<<5)
#define XENOA_HIDE_TRAIT		(1<<6)

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
#define XENOA_ACTIVATION_SPECIAL "XENOA_ACTIVATION_SPECIAL"

///Distance for trait name balloon hint
#define XENOA_TRAIT_BALLOON_HINT_DIST 3

///Common defines for trait hints
#define XENOA_TRAIT_HINT_MATERIAL list("icon" = "eye", "desc" = "This trait can appear in the artifact's material description.")
#define XENOA_TRAIT_HINT_INHAND list("icon" = "hand-sparkles", "desc" = "This trait can be detected by 'feeling' the artifact.")
#define XENOA_TRAIT_HINT_TRIGGER(X) list("icon" = "wrench", "desc" = "This trait can be triggered with a [X].")
#define XENOA_TRAIT_HINT_DETECT(X) list("icon" = "search", "desc" = "This trait can be detected with a [X].")
#define XENOA_TRAIT_HINT_TWIN list("icon" = "clone", "desc" = "This trait has sister traits which perform a similar, but unique, action.")
#define XENOA_TRAIT_HINT_TWIN_VARIANT(X) list("icon" = "fingerprint", "desc" = "This variant will [X].")
#define XENOA_TRAIT_HINT_RANDOMISED list("icon" = "dice", "desc" = "This trait's effects may differ between instances.")
#define XENOA_TRAIT_HINT_APPEARANCE(X) list("icon" = "snowflake", "desc" = "This trait's changes the artifact's appearance. [X]")
#define XENOA_TRAIT_HINT_SOUND(X) list("icon" = "volume-up", "desc" = "This trait will passively make noise. listen for [X].")
