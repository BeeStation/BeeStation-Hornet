/*ALL DNA, SPECIES, AND GENETICS-RELATED DEFINES GO HERE*/

#define CHECK_DNA_AND_SPECIES(C) if((!(C.dna)) || (!(C.dna.species))) return

#define UI_CHANGED "ui changed"
#define UE_CHANGED "ue changed"
#define UF_CHANGED "uf changed"

#define CHAMELEON_MUTATION_DEFAULT_TRANSPARENCY 204

// String identifiers for associative list lookup

// Types of usual mutations
#define	POSITIVE 			1
#define	NEGATIVE			2
#define	MINOR_NEGATIVE		4


//Mutation classes. Normal being on them, extra being additional mutations with instability and other being stuff you dont want people to fuck with like wizard mutate
/// A mutation that can be activated and deactived by completing a sequence
#define MUT_NORMAL 1
/// A mutation that is in the mutations tab, and can be given and taken away through though the DNA console. Has a 0 before it's name in the mutation section of the dna console
#define MUT_EXTRA 2
/// Cannot be interacted with by players through normal means. I.E. wizards mutate
#define MUT_OTHER 3

// DNA - Because fuck you and your magic numbers being all over the codebase.
#define DNA_BLOCK_SIZE 3

#define DNA_BLOCK_SIZE_COLOR DEFAULT_HEX_COLOR_LEN

#define DNA_GENDER_BLOCK 1
#define DNA_SKIN_TONE_BLOCK 2
#define DNA_EYE_COLOR_BLOCK 3
#define DNA_HAIRSTYLE_BLOCK 4
#define DNA_HAIR_COLOR_BLOCK 5
#define DNA_FACIAL_HAIRSTYLE_BLOCK 6
#define DNA_FACIAL_HAIR_COLOR_BLOCK 7
#define DNA_HAIRSTYLE_GRADIENT_BLOCK 8
#define DNA_HAIR_COLOR_GRADIENT_BLOCK 9
#define DNA_FACIAL_HAIRSTYLE_GRADIENT_BLOCK 10
#define DNA_FACIAL_HAIR_COLOR_GRADIENT_BLOCK 11

#define DNA_UNI_IDENTITY_BLOCKS 11

/// This number needs to equal the total number of DNA blocks
#define DNA_FEATURE_BLOCKS 29

#define DNA_MUTANT_COLOR_BLOCK 1
#define DNA_ETHEREAL_COLOR_BLOCK 2
#define DNA_LIZARD_MARKINGS_BLOCK 3
#define DNA_TAIL_BLOCK 4
#define DNA_LIZARD_TAIL_BLOCK 5
#define DNA_SNOUT_BLOCK 6
#define DNA_HORNS_BLOCK 7
#define DNA_FRILLS_BLOCK 8
#define DNA_SPINES_BLOCK 9
#define DNA_EARS_BLOCK 10
#define DNA_MOTH_WINGS_BLOCK 11
#define DNA_MOTH_ANTENNAE_BLOCK 12
#define DNA_MOTH_MARKINGS_BLOCK 13
#define DNA_APID_ANTENNA_BLOCK 14
#define DNA_APID_STRIPES_BLOCK 15
#define DNA_APID_HEADSTRIPES_BLOCK 16
#define DNA_PSYPHOZA_CAP_BLOCK 17
#define DNA_INSECT_TYPE_BLOCK 18
#define DNA_IPC_SCREEN_BLOCK 19
#define DNA_IPC_ANTENNA_BLOCK 20
#define DNA_IPC_CHASSIS_BLOCK 21
#define DNA_DIONA_LEAVES_BLOCK 22
#define DNA_DIONA_THORNS_BLOCK 23
#define DNA_DIONA_FLOWERS_BLOCK 24
#define DNA_DIONA_MOSS_BLOCK 25
#define DNA_DIONA_MUSHROOM_BLOCK 26
#define DNA_DIONA_ANTENNAE_BLOCK 27
#define DNA_DIONA_EYES_BLOCK 28
#define DNA_DIONA_PBODY_BLOCK 29

#define DNA_SEQUENCE_LENGTH 4
#define DNA_MUTATION_BLOCKS 8
#define DNA_UNIQUE_ENZYMES_LEN 32

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

/// Used for determining which wounds are applicable to this species.
/// if we have flesh (can suffer slash/piercing/burn wounds, requires they don't have NOBLOOD)
// #define HAS_FLESH 23 [add if we ever port TGs wound system]
/// if we have bones (can suffer bone wounds)
// #define HAS_BONE 24 [add if we ever port TGs wound system]
/// If we have a limb-specific overlay sprite
#define HAS_MARKINGS 25

//organ slots
#define ORGAN_SLOT_ADAMANTINE_RESONATOR "adamantine_resonator"
#define ORGAN_SLOT_APPENDIX "appendix"
#define ORGAN_SLOT_BRAIN "brain"
#define ORGAN_SLOT_BRAIN_ANTIDROP "brain_antidrop"
#define ORGAN_SLOT_BRAIN_ANTISTUN "brain_antistun"
#define ORGAN_SLOT_BRAIN_SURGICAL_IMPLANT "brain_surgical"
#define ORGAN_SLOT_BREATHING_TUBE "breathing_tube"
#define ORGAN_SLOT_EARS "ears"
#define ORGAN_SLOT_EYES "eye_sight"
#define ORGAN_SLOT_HEART "heart"
#define ORGAN_SLOT_HEART_AID "heartdrive"
#define ORGAN_SLOT_HUD "eye_hud"
#define ORGAN_SLOT_LIVER "liver"
#define ORGAN_SLOT_LUNGS "lungs"
#define ORGAN_SLOT_PARASITE_EGG "parasite_egg"
#define ORGAN_SLOT_MONSTER_CORE "monstercore"
#define ORGAN_SLOT_RIGHT_ARM_AUG "r_arm_device"
#define ORGAN_SLOT_LEFT_ARM_AUG "l_arm_device"
#define ORGAN_SLOT_STOMACH "stomach"
#define ORGAN_SLOT_STOMACH_AID "stomach_aid"
#define ORGAN_SLOT_THRUSTERS "thrusters"
#define ORGAN_SLOT_TONGUE "tongue"
#define ORGAN_SLOT_VOICE "vocal_cords"
#define ORGAN_SLOT_ZOMBIE "zombie_infection"

#define ORGAN_SLOT_R_ARM_NYMPH "r_arm_nymph" //I can't think of any way of doing this better, please tell me if there is a better way.
#define ORGAN_SLOT_L_ARM_NYMPH "l_arm_nymph"
#define ORGAN_SLOT_R_LEG_NYMPH "r_leg_nymph"
#define ORGAN_SLOT_L_LEG_NYMPH "l_leg_nymph"
#define ORGAN_SLOT_CHEST_NYMPH "chest_nymph"

/// Organ slot external
#define ORGAN_SLOT_EXTERNAL_TAIL "tail"
#define ORGAN_SLOT_EXTERNAL_SPINES "spines"
#define ORGAN_SLOT_EXTERNAL_SNOUT "snout"
#define ORGAN_SLOT_EXTERNAL_FRILLS "frills"
#define ORGAN_SLOT_EXTERNAL_HORNS "horns"
#define ORGAN_SLOT_EXTERNAL_WINGS "wings"
#define ORGAN_SLOT_EXTERNAL_ANTENNAE "antennae"
#define ORGAN_SLOT_EXTERNAL_BODYMARKINGS "bodymarkings"

/// Xenomorph organ slots
#define ORGAN_SLOT_XENO_PLASMAVESSEL "plasma_vessel"
#define ORGAN_SLOT_XENO_HIVENODE "hive_node"
#define ORGAN_SLOT_XENO_RESINSPINNER "resin_spinner"
#define ORGAN_SLOT_XENO_ACIDGLAND "acid_gland"
#define ORGAN_SLOT_XENO_NEUROTOXINGLAND "neurotoxin_gland"
#define ORGAN_SLOT_XENO_EGGSAC "eggsac"

//organ defines
#define STANDARD_ORGAN_THRESHOLD 100
#define STANDARD_ORGAN_HEALING 0.0005
#define STANDARD_ORGAN_DECAY 0.00037 //designed to fail organs when left to decay for ~45 minutes

// used for the can_chromosome var on mutations
#define CHROMOSOME_NEVER 0
#define CHROMOSOME_NONE 1
#define CHROMOSOME_USED 2

//used for mob's genetic gender (mainly just for pronouns, members of sexed species with plural gender refer to their physique for the actual sprites, which is not genetic)
#define GENDERS 3
#define G_MALE 1
#define G_FEMALE 2
#define G_PLURAL 3

/// Defines how a mob's organs_slot is ordered
/// Exists so Life()'s organ process order is consistent
GLOBAL_LIST_INIT(organ_process_order, list(
	ORGAN_SLOT_BRAIN,
	ORGAN_SLOT_APPENDIX,
	ORGAN_SLOT_RIGHT_ARM_AUG,
	ORGAN_SLOT_LEFT_ARM_AUG,
	ORGAN_SLOT_STOMACH,
	ORGAN_SLOT_STOMACH_AID,
	ORGAN_SLOT_BREATHING_TUBE,
	ORGAN_SLOT_EARS,
	ORGAN_SLOT_EYES,
	ORGAN_SLOT_LUNGS,
	ORGAN_SLOT_HEART,
	ORGAN_SLOT_ZOMBIE,
	ORGAN_SLOT_THRUSTERS,
	ORGAN_SLOT_HUD,
	ORGAN_SLOT_LIVER,
	ORGAN_SLOT_TONGUE,
	ORGAN_SLOT_VOICE,
	ORGAN_SLOT_ADAMANTINE_RESONATOR,
	ORGAN_SLOT_HEART_AID,
	ORGAN_SLOT_BRAIN_ANTIDROP,
	ORGAN_SLOT_BRAIN_ANTISTUN,
	ORGAN_SLOT_PARASITE_EGG,
	ORGAN_SLOT_MONSTER_CORE,
	ORGAN_SLOT_XENO_PLASMAVESSEL,
	ORGAN_SLOT_XENO_HIVENODE,
	ORGAN_SLOT_XENO_RESINSPINNER,
	ORGAN_SLOT_XENO_ACIDGLAND,
	ORGAN_SLOT_XENO_NEUROTOXINGLAND,
	ORGAN_SLOT_XENO_EGGSAC,))

//Size / height stuff
#define SPECIES_HEIGHTS(x, y, z) list("Short" = x, "Normal" = y, "Tall" = z)
