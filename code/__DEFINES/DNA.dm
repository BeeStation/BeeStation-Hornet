/*ALL DNA, SPECIES, AND GENETICS-RELATED DEFINES GO HERE*/

#define CHECK_DNA_AND_SPECIES(C) if((!(C.dna)) || (!(C.dna.species))) return

// Defines copying names of mutations in all cases, make sure to change this if you change mutation's type
#define HULK		/datum/mutation/hulk
#define XRAY		/datum/mutation/thermal/x_ray
#define SPACEMUT	/datum/mutation/space_adaptation
#define TK			/datum/mutation/telekinesis
#define NERVOUS		/datum/mutation/nervousness
#define EPILEPSY	/datum/mutation/epilepsy
#define MUTATE		/datum/mutation/bad_dna
#define COUGH		/datum/mutation/cough
#define DWARFISM	/datum/mutation/dwarfism
#define GIGANTISM	/datum/mutation/gigantism
#define CLOWNMUT	/datum/mutation/clumsy
#define TOURETTES	/datum/mutation/tourettes
#define DEAFMUT		/datum/mutation/deaf
#define BLINDMUT	/datum/mutation/blind
#define RACEMUT		/datum/mutation/race
#define BADSIGHT	/datum/mutation/nearsight
#define LASEREYES	/datum/mutation/laser_eyes
#define CHAMELEON	/datum/mutation/chameleon
#define WACKY		/datum/mutation/wacky
#define MUT_MUTE	/datum/mutation/mute
#define SMILE		/datum/mutation/smile
#define STONER		/datum/mutation/stoner
#define UNINTELLIGIBLE		/datum/mutation/unintelligible
#define SWEDISH		/datum/mutation/swedish
#define CHAV		/datum/mutation/chav
#define ELVIS		/datum/mutation/elvis
#define RADIOACTIVE	/datum/mutation/radioactive
#define GLOWY		/datum/mutation/glow
#define ANTIGLOWY	/datum/mutation/glow/anti
#define TELEPATHY	/datum/mutation/telepathy
#define FIREBREATH	/datum/mutation/firebreath
#define VOID		/datum/mutation/void
#define STRONG    	/datum/mutation/strong
#define FIRESWEAT	/datum/mutation/fire
#define THERMAL		/datum/mutation/thermal
#define ANTENNA		/datum/mutation/antenna
#define PARANOIA	/datum/mutation/paranoia
#define INSULATED	/datum/mutation/insulated
#define SHOCKTOUCH	/datum/mutation/shock
#define OLFACTION	/datum/mutation/olfaction
#define ACIDFLESH	/datum/mutation/acidflesh
#define BADBLINK	/datum/mutation/badblink
#define SPASTIC		/datum/mutation/spastic
#define EXTRASTUN	/datum/mutation/extrastun
#define GELADIKINESIS		/datum/mutation/geladikinesis
#define CRYOKINESIS /datum/mutation/cryokinesis
#define CLUWNEMUT   /datum/mutation/cluwne
#define WAXSALIVA   /datum/mutation/wax_saliva
#define STRONGWINGS /datum/mutation/strongwings
#define CATCLAWS    /datum/mutation/catclaws
#define OVERLOAD    /datum/mutation/overload
#define ACIDOOZE    /datum/mutation/acidooze
#define MEDIEVAL    /datum/mutation/medieval

#define UI_CHANGED "ui changed"
#define UE_CHANGED "ue changed"

#define CHAMELEON_MUTATION_DEFAULT_TRANSPARENCY 204

// String identifiers for associative list lookup

// Types of usual mutations
#define	POSITIVE 			1
#define	NEGATIVE			2
#define	MINOR_NEGATIVE		4


// Mutation classes. Normal being on them, extra being additional mutations with instability and other being stuff you dont want people to fuck with like wizard mutate
#define MUT_NORMAL 1
#define MUT_EXTRA 2
#define MUT_OTHER 3

// DNA - Because fuck you and your magic numbers being all over the codebase.
#define DNA_BLOCK_SIZE				3

#define DNA_UNI_IDENTITY_BLOCKS			9
#define DNA_HAIR_COLOR_BLOCK			1
#define DNA_FACIAL_HAIR_COLOR_BLOCK		2
#define DNA_SKIN_TONE_BLOCK				3
#define DNA_EYE_COLOR_BLOCK				4
#define DNA_GENDER_BLOCK				5
#define DNA_FACIAL_HAIR_STYLE_BLOCK		6
#define DNA_HAIR_STYLE_BLOCK			7
#define DNA_HAIR_GRADIENT_COLOR_BLOCK	8
#define DNA_HAIR_GRADIENT_STYLE_BLOCK	9

#define DNA_SEQUENCE_LENGTH			4
#define DNA_MUTATION_BLOCKS			8
#define DNA_UNIQUE_ENZYMES_LEN		32

//Transformation proc stuff
#define TR_KEEPITEMS	(1<<0)
#define TR_KEEPVIRUS	(1<<1)
#define TR_KEEPDAMAGE	(1<<2)
#define TR_HASHNAME		(1<<3)	// hashing names (e.g. monkey(e34f)) (only in monkeyize)
#define TR_KEEPIMPLANTS	(1<<4)
#define TR_KEEPSE		(1<<5)	// changelings shouldn't edit the DNA's SE when turning into a monkey
#define TR_DEFAULTMSG	(1<<6)
#define TR_KEEPORGANS	(1<<8)
#define TR_KEEPAI 		(1<<9)

#define CLONER_FRESH_CLONE "fresh"
#define CLONER_MATURE_CLONE "mature"

//! ## species traits for mutantraces
#define MUTCOLORS		1
#define HAIR			2
#define FACEHAIR		3
#define EYECOLOR		4
#define LIPS			5
#define NOBLOOD			6
#define NOTRANSSTING	7
#define MUTCOLORS_PARTSONLY	8	//! Used if we want the mutant colour to be only used by mutant bodyparts. Don't combine this with MUTCOLORS, or it will be useless.
#define NOZOMBIE		9
#define NO_UNDERWEAR	10
#define NOLIVER			11
#define NOSTOMACH		12
#define NO_DNA_COPY     13
#define NOFLASH			14
#define DYNCOLORS		15 //! Use this if you want to change the race's color without the player being able to pick their own color. AKA special color shifting TRANSLATION: AWFUL.
#define AGENDER			16
#define NOEYESPRITES	17 //! Do not draw eyes or eyeless overlay
#define NOREAGENTS     18 //! DO NOT PROCESS REAGENTS
#define REVIVESBYHEALING 19 // Will revive on heal when healing and total HP > 0.
#define NOHUSK			20 // Can't be husked.
#define NOMOUTH			21
#define NOSOCKS       22 // You cannot wear socks.

/// Used for determining which wounds are applicable to this species.
/// if we have flesh (can suffer slash/piercing/burn wounds, requires they don't have NOBLOOD)
// #define HAS_FLESH 23 [add if we ever port TGs wound system]
/// if we have bones (can suffer bone wounds)
// #define HAS_BONE 24 [add if we ever port TGs wound system]
/// If we have a limb-specific overlay sprite
#define HAS_MARKINGS 25

//organ slots
#define ORGAN_SLOT_BRAIN "brain"
#define ORGAN_SLOT_APPENDIX "appendix"
#define ORGAN_SLOT_RIGHT_ARM_AUG "r_arm_device"
#define ORGAN_SLOT_LEFT_ARM_AUG "l_arm_device"
#define ORGAN_SLOT_STOMACH "stomach"
#define ORGAN_SLOT_STOMACH_AID "stomach_aid"
#define ORGAN_SLOT_BREATHING_TUBE "breathing_tube"
#define ORGAN_SLOT_EARS "ears"
#define ORGAN_SLOT_EYES "eye_sight"
#define ORGAN_SLOT_LUNGS "lungs"
#define ORGAN_SLOT_HEART "heart"
#define ORGAN_SLOT_ZOMBIE "zombie_infection"
#define ORGAN_SLOT_THRUSTERS "thrusters"
#define ORGAN_SLOT_HUD "eye_hud"
#define ORGAN_SLOT_LIVER "liver"
#define ORGAN_SLOT_TONGUE "tongue"
#define ORGAN_SLOT_VOICE "vocal_cords"
#define ORGAN_SLOT_ADAMANTINE_RESONATOR "adamantine_resonator"
#define ORGAN_SLOT_HEART_AID "heartdrive"
#define ORGAN_SLOT_BRAIN_ANTIDROP "brain_antidrop"
#define ORGAN_SLOT_BRAIN_ANTISTUN "brain_antistun"
#define ORGAN_SLOT_BRAIN_SURGICAL_IMPLANT "brain_surgical"
#define ORGAN_SLOT_TAIL "tail"
#define ORGAN_SLOT_WINGS "wings"

//organ defines
#define STANDARD_ORGAN_THRESHOLD 	100
#define STANDARD_ORGAN_HEALING 		0.001
#define STANDARD_ORGAN_DECAY		0.00074	//designed to fail organs when left to decay for ~45 minutes

// used for the can_chromosome var on mutations
#define CHROMOSOME_NEVER 0
#define CHROMOSOME_NONE 1
#define CHROMOSOME_USED 2

#define G_MALE 1
#define G_FEMALE 2
#define G_PLURAL 3
