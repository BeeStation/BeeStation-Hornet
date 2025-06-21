//Defines for Species IDs
#define SPECIES_ABDUCTOR "abductor"
#define SPECIES_ANDROID "android"
#define SPECIES_APID "apid"
#define SPECIES_DEBUG "debug"
#define SPECIES_DULLAHAN "dullahan"
#define SPECIES_ETHEREAL "ethereal"
#define SPECIES_FELINID "felinid"
#define SPECIES_FLY "fly"
#define SPECIES_HUMAN "human"
#define SPECIES_IPC "ipc"
#define SPECIES_LIZARD "lizard"
#define SPECIES_ASHWALKER "ashlizard"
#define SPECIES_NIGHTMARE "nightmare"
#define SPECIES_MONKEY "monkey"
#define SPECIES_MOTH "moth"
#define SPECIES_OOZELING "oozeling"
#define SPECIES_LUMINESCENT "lum"
#define SPECIES_SLIMEPERSON "slime"
#define SPECIES_STARGAZER "stargazer"
#define SPECIES_PLASMAMAN "plasmaman"
#define SPECIES_DIONA "diona"
#define SPECIES_PUMPKINPERSON "pumpkin_man"
#define SPECIES_SHADOWPERSON "shadow"
#define SPECIES_SKELETON "skeleton"
#define SPECIES_SNAILPERSON "snail"
#define SPECIES_SUPERSOLDIER "supersoldier"
#define SPECIES_VAMPIRE "vampire"
#define SPECIES_PSYPHOZA "psyphoza"

//Defines for Golem Species IDs
#define SPECIES_GOLEM_ADAMANTINE "adamantine_golem"
#define SPECIES_GOLEM_ALLOY "alloy_golem"
#define SPECIES_GOLEM_BANANIUM "bananium_golem"
#define SPECIES_GOLEM_BLUESPACE "bluespace_golem"
#define SPECIES_GOLEM_BONE "bone_golem"
#define SPECIES_GOLEM_BRONZE "bronze_golem"
#define SPECIES_GOLEM_CAPITALIST "capitalist_golem"
#define SPECIES_GOLEM_CARDBOARD "cardboard_golem"
#define SPECIES_GOLEM_CLOCKWORK "clockwork_golem"
#define SPECIES_GOLEM_CLOCKWORK_SERVANT "clockwork golem servant"
#define SPECIES_GOLEM_CLOTH "cloth_golem"
#define SPECIES_GOLEM_COPPER "copper_golem"
#define SPECIES_GOLEM_DIAMOND "diamond_golem"
#define SPECIES_GOLEM_DURATHREAD "durathread_golem"
#define SPECIES_GOLEM_GLASS "glass_golem"
#define SPECIES_GOLEM_GOLD "gold_golem"
#define SPECIES_GOLEM_IRON "iron_golem"
#define SPECIES_GOLEM_LEATHER "leather_golem"
#define SPECIES_GOLEM_PLASMA "plasma_golem"
#define SPECIES_GOLEM_PLASTEEL "plasteel_golem"
#define SPECIES_GOLEM_PLASTIC "plastic_golem"
#define SPECIES_GOLEM_PLASTITANIUM "plastitanium_golem"
#define SPECIES_GOLEM_RUNIC "cult_golem"
#define SPECIES_GOLEM_SAND "sand_golem"
#define SPECIES_GOLEM_SILVER "silver_golem"
#define SPECIES_GOLEM_SNOW "snow_golem"
#define SPECIES_GOLEM_SOVIET "soviet_golem"
#define SPECIES_GOLEM_TITANIUM "titanium_golem"
#define SPECIES_GOLEM_URANIUM "uranium_golem"
#define SPECIES_GOLEM_WOOD "wood_golem"

//Species bitflags, used for species_restricted. If this somehow ever gets above 23 Bee has larger problems.
#define FLAG_HUMAN			(1<<0)
#define FLAG_IPC			(1<<1)
#define FLAG_ETHEREAL		(1<<2)
#define FLAG_PLASMAMAN		(1<<3)
#define	FLAG_APID			(1<<4)
#define FLAG_MOTH			(1<<5)
#define FLAG_LIZARD			(1<<6)
#define FLAG_FELINID		(1<<7)
#define FLAG_OOZELING		(1<<8)
#define FLAG_FLY			(1<<9)
#define FLAG_DEBUG_SPECIES	(1<<10)
#define FLAG_MONKEY			(1<<11)
#define FLAG_PSYPHOZA		(1<<12)
#define FLAG_DIONA			(1<<13)

#define FEATURE_NONE "None" //For usage in species_features, for checking for marking names.

// Defines for used in creating "perks" for the species preference pages.
/// A key that designates UI icon displayed on the perk.
#define SPECIES_PERK_ICON "ui_icon"
/// A key that designates the name of the perk.
#define SPECIES_PERK_NAME "name"
/// A key that designates the description of the perk.
#define SPECIES_PERK_DESC "description"
/// A key that designates what type of perk it is (see below).
#define SPECIES_PERK_TYPE "perk_type"

// The possible types each perk can be.
// Positive perks are shown in green, negative in red, and neutral in grey.
#define SPECIES_POSITIVE_PERK "positive"
#define SPECIES_NEGATIVE_PERK "negative"
#define SPECIES_NEUTRAL_PERK "neutral"

//! ## control what things can spawn species
/// Badmin magic mirror
#define MIRROR_BADMIN (1<<0)
/// Standard magic mirror (wizard)
#define MIRROR_MAGIC  (1<<1)
/// Pride ruin mirror
#define MIRROR_PRIDE  (1<<2)
/// Race swap wizard event
#define RACE_SWAP     (1<<3)
/// ERT spawn template (avoid races that don't function without correct gear)
#define ERT_SPAWN     (1<<4)
/// xenobio black crossbreed
#define SLIME_EXTRACT (1<<5)
/// Wabbacjack staff projectiles
#define WABBAJACK     (1<<6)

// Randomization keys for calling wabbajack with.
// Note the contents of these keys are important, as they're displayed to the player
// Ex: (You turn into a "monkey", You turn into a "xenomorph")
#define WABBAJACK_MONKEY "monkey"
#define WABBAJACK_ROBOT "robot"
#define WABBAJACK_SLIME "slime"
#define WABBAJACK_XENO "xenomorph"
#define WABBAJACK_HUMAN "humanoid"
#define WABBAJACK_ANIMAL "animal"

// Sounds used by species for "nasal/lungs" emotes - the DEFAULT being used mainly by humans, lizards, and ethereals becase biology idk

#define SPECIES_DEFAULT_COUGH_SOUND(user) user.gender == FEMALE ? pick(\
		'sound/emotes/female/female_cough_1.ogg',\
		'sound/emotes/female/female_cough_2.ogg',\
		'sound/emotes/female/female_cough_3.ogg',\
		'sound/emotes/female/female_cough_4.ogg',\
		'sound/emotes/female/female_cough_5.ogg',\
		'sound/emotes/female/female_cough_6.ogg',\
		'sound/emotes/female/female_cough_7.ogg') : pick(\
		'sound/emotes/male/male_cough_1.ogg',\
		'sound/emotes/male/male_cough_2.ogg',\
		'sound/emotes/male/male_cough_3.ogg')
#define SPECIES_DEFAULT_GASP_SOUND(user) user.gender == FEMALE ? pick(\
		'sound/emotes/female/gasp_f1.ogg',\
		'sound/emotes/female/gasp_f2.ogg',\
		'sound/emotes/female/gasp_f3.ogg',\
		'sound/emotes/female/gasp_f4.ogg',\
		'sound/emotes/female/gasp_f5.ogg',\
		'sound/emotes/female/gasp_f6.ogg') : pick(\
		'sound/emotes/male/gasp_m1.ogg',\
		'sound/emotes/male/gasp_m2.ogg',\
		'sound/emotes/male/gasp_m3.ogg',\
		'sound/emotes/male/gasp_m4.ogg',\
		'sound/emotes/male/gasp_m5.ogg',\
		'sound/emotes/male/gasp_m6.ogg')
#define SPECIES_DEFAULT_SIGH_SOUND(user) user.gender == FEMALE ? 'sound/emotes/female/female_sigh.ogg' : 'sound/emotes/male/male_sigh.ogg'
#define SPECIES_DEFAULT_SNEEZE_SOUND(user) user.gender == FEMALE ? pick(\
		'sound/emotes/female/female_sneeze1.ogg',\
		'sound/emotes/female/female_sneeze2.ogg') : pick(\
		'sound/emotes/male/male_sneeze1.ogg',\
		'sound/emotes/male/male_sneeze2.ogg')
#define SPECIES_DEFAULT_SNIFF_SOUND(user) user.gender == FEMALE ? 'sound/emotes/female/female_sniff.ogg' : 'sound/emotes/male/male_sniff.ogg'
#define SPECIES_DEFAULT_GIGGLE_SOUND(user) user.gender == FEMALE ? pick(\
		'sound/emotes/female/female_giggle_1.ogg',\
		'sound/emotes/female/female_giggle_2.ogg') : pick(\
		'sound/emotes/male/male_giggle_1.ogg',\
		'sound/emotes/male/male_giggle_2.ogg',\
		'sound/emotes/male/male_giggle_3.ogg')
