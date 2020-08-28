/*ALL DNA, SPECIES, AND GENETICS-RELATED DEFINES GO HERE*/

#define CHECK_DNA_AND_SPECIES(C) if((!(C.dna)) || (!(C.dna.species))) return

// Defines copying names of mutations in all cases, make sure to change this if you change mutation's type
#define HULK		/datum/mutation/human/hulk
#define XRAY		/datum/mutation/human/thermal/x_ray
#define SPACEMUT	/datum/mutation/human/space_adaptation
#define TK			/datum/mutation/human/telekinesis
#define NERVOUS		/datum/mutation/human/nervousness
#define EPILEPSY	/datum/mutation/human/epilepsy
#define MUTATE		/datum/mutation/human/bad_dna
#define COUGH		/datum/mutation/human/cough
#define DWARFISM	/datum/mutation/human/dwarfism
#define GIGANTISM	/datum/mutation/human/gigantism
#define CLOWNMUT	/datum/mutation/human/clumsy
#define TOURETTES	/datum/mutation/human/tourettes
#define DEAFMUT		/datum/mutation/human/deaf
#define BLINDMUT	/datum/mutation/human/blind
#define RACEMUT		/datum/mutation/human/race
#define BADSIGHT	/datum/mutation/human/nearsight
#define LASEREYES	/datum/mutation/human/laser_eyes
#define CHAMELEON	/datum/mutation/human/chameleon
#define WACKY		/datum/mutation/human/wacky
#define MUT_MUTE	/datum/mutation/human/mute
#define SMILE		/datum/mutation/human/smile
#define STONER		/datum/mutation/human/stoner
#define UNINTELLIGIBLE		/datum/mutation/human/unintelligible
#define SWEDISH		/datum/mutation/human/swedish
#define CHAV		/datum/mutation/human/chav
#define ELVIS		/datum/mutation/human/elvis
#define RADIOACTIVE	/datum/mutation/human/radioactive
#define GLOWY		/datum/mutation/human/glow
#define ANTIGLOWY	/datum/mutation/human/glow/anti
#define TELEPATHY	/datum/mutation/human/telepathy
#define FIREBREATH	/datum/mutation/human/firebreath
#define VOID		/datum/mutation/human/void
#define STRONG    	/datum/mutation/human/strong
#define FIRESWEAT	/datum/mutation/human/fire
#define THERMAL		/datum/mutation/human/thermal
#define ANTENNA		/datum/mutation/human/antenna
#define PARANOIA	/datum/mutation/human/paranoia
#define MINDREAD	/datum/mutation/human/mindreader
#define INSULATED	/datum/mutation/human/insulated
#define SHOCKTOUCH	/datum/mutation/human/shock
#define OLFACTION	/datum/mutation/human/olfaction
#define ACIDFLESH	/datum/mutation/human/acidflesh
#define BADBLINK	/datum/mutation/human/badblink
#define SPASTIC		/datum/mutation/human/spastic
#define EXTRASTUN	/datum/mutation/human/extrastun
#define GELADIKINESIS		/datum/mutation/human/geladikinesis
#define CRYOKINESIS /datum/mutation/human/cryokinesis
#define CLUWNEMUT   /datum/mutation/human/cluwne

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

#define DNA_UNI_IDENTITY_BLOCKS		7
#define DNA_HAIR_COLOR_BLOCK		1
#define DNA_FACIAL_HAIR_COLOR_BLOCK	2
#define DNA_SKIN_TONE_BLOCK			3
#define DNA_EYE_COLOR_BLOCK			4
#define DNA_GENDER_BLOCK			5
#define DNA_FACIAL_HAIR_STYLE_BLOCK	6
#define DNA_HAIR_STYLE_BLOCK		7

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
#define DIGITIGRADE		10	//! Uses weird leg sprites. Optional for Lizards, required for ashwalkers. Don't give it to other races unless you make sprites for this (see human_parts_greyscale.dmi)
#define NO_UNDERWEAR	11
#define NOLIVER			12
#define NOSTOMACH		13
#define NO_DNA_COPY     14
#define DRINKSBLOOD		15
#define NOFLASH			16
#define DYNCOLORS		17 //! Use this if you want to change the race's color without the player being able to pick their own color. AKA special color shifting
#define AGENDER			18
#define NOEYESPRITES	19 //! Do not draw eyes or eyeless overlay
#define NOREAGENTS     20 //! DO NOT PROCESS REAGENTS
#define REVIVESBYHEALING 21 // Will revive on heal when healing and total HP > 0.
#define NOHUSK			22 // Can't be husked.
#define ROBOTIC_LIMBS	23 //limbs start out as robotic; but also use organic icons. If you want to use the default ones, you'll have to use on_species_gain
#define NOMOUTH			24

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
#define ORGAN_SLOT_TAIL "tail"
#define ORGAN_SLOT_WINGS "wings"

//organ defines
#define STANDARD_ORGAN_THRESHOLD 	100
#define STANDARD_ORGAN_HEALING 		0.001
#define STANDARD_ORGAN_DECAY		0.00222		//designed to fail organs when left to decay for ~15 minutes

// used for the can_chromosome var on mutations
#define CHROMOSOME_NEVER 0
#define CHROMOSOME_NONE 1
#define CHROMOSOME_USED 2

#define G_MALE 1
#define G_FEMALE 2
#define G_PLURAL 3
