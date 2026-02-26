/// Helper to figure out if an organ is organic
#define IS_ORGANIC_ORGAN(organ) (organ.organ_flags & ORGAN_ORGANIC)
/// Helper to figure out if an organ is robotic
#define IS_ROBOTIC_ORGAN(organ) (organ.organ_flags & ORGAN_ROBOTIC)

// Flags for the organ_flags var on /obj/item/organ
/// Organic organs, the default. Don't get affected by EMPs.
#define ORGAN_ORGANIC (1<<0)
/// Synthetic organs, or cybernetic organs. Reacts to EMPs and don't deteriorate or heal
#define ORGAN_ROBOTIC (1<<1)
/// Mineral organs. Snowflakey.
#define ORGAN_MINERAL (1<<2)
/// Frozen organs, don't deteriorate
#define ORGAN_FROZEN (1<<3)
/// Failing organs perform damaging effects until replaced or fixed, and typically they don't function properly either
#define ORGAN_FAILING (1<<4)
/// Synthetic organ affected by an EMP. Deteriorates over time.
#define ORGAN_EMP (1<<5)
/// Currently only the brain - Removing this organ KILLS the owner
#define ORGAN_VITAL (1<<6)
/// Can be eaten
#define ORGAN_EDIBLE (1<<7)
/// Can't be removed using surgery or other common means
#define ORGAN_UNREMOVABLE (1<<8)
/// Can't be seen by scanners, doesn't anger body purists
#define ORGAN_HIDDEN (1<<9)

/// Helper to figure out if a limb is organic
#define IS_ORGANIC_LIMB(limb) (limb.bodytype & BODYTYPE_ORGANIC)
/// Helper to figure out if a limb is robotic
#define IS_ROBOTIC_LIMB(limb) (limb.bodytype & BODYTYPE_ROBOTIC)

// Flags for the bodypart_flags var on /obj/item/bodypart
/// Bodypart cannot be dismembered or amputated
#define BODYPART_UNREMOVABLE (1<<0)
/// Bodypart is a pseudopart (like a chainsaw arm)
#define BODYPART_PSEUDOPART (1<<1)
/// Bodypart did not match the owner's default bodypart limb_id when surgically implanted
#define BODYPART_IMPLANTED (1<<2)

// Bodypart change blocking flags
///Bodypart does not get replaced during set_species()
#define BP_BLOCK_CHANGE_SPECIES (1<<0)
