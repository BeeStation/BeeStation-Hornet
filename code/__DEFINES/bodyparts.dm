#define IS_ORGANIC_LIMB(A) (A && (A.bodytype & BODYTYPE_ORGANIC))
#define IS_ROBOTIC_LIMB(A) (A && (A.bodytype & BODYTYPE_ROBOTIC))

#define BODYZONE_STYLE_DEFAULT 0
#define BODYZONE_STYLE_MEDICAL 1

#define BODYZONE_CONTEXT_COMBAT 0
#define BODYZONE_CONTEXT_INJECTION 1
#define BODYZONE_CONTEXT_ROBOTIC_LIMB_HEALING 2

/// Amount of injury damage taken when the damage is blunt
#define BLUNT_DAMAGE_RATIO 1
/// If the sharpness delta between weapon and armour is below this value, sharpness damage
/// will start to be converted into blunt damage.
#define BLUNT_DAMAGE_START 30
/// If the sharpness delta between weapon and armour falls below this value, then the
/// injury damage application process is aborted.
#define INJURY_PENETRATION_MINIMUM -20
/// The multiplier for organ damage for attacks that penetrate all the way down to them
#define ORGAN_DAMAGE_MULTIPLIER 1
