#define IS_ORGANIC_LIMB(A) (A && (A.bodytype & BODYTYPE_ORGANIC))
#define IS_ROBOTIC_LIMB(A) (A && (A.bodytype & BODYTYPE_ROBOTIC))

#define BODYZONE_STYLE_DEFAULT 0
#define BODYZONE_STYLE_MEDICAL 1

#define BODYZONE_CONTEXT_COMBAT 0
#define BODYZONE_CONTEXT_INJECTION 1
#define BODYZONE_CONTEXT_ROBOTIC_LIMB_HEALING 2

/// Amount of injury damage taken when the damage is blunt
#define BLUNT_DAMAGE_RATIO 1
/// Point at which injury damage starts to turn blunt
#define BLUNT_DAMAGE_START 30
/// Point at which damage can no longer apply
#define INJURY_PENETRATION_MINIMUM -20
/// Damage for a minor injury
#define INJURY_MINOR_DAMAGE 0
/// Damage for a major injury
#define INJURY_MAJOR_DAMAGE 15
/// Damage for a critical injury
#define INJURY_CRITICAL_DAMAGE 30
/// The multiplier for organ damage for attacks that penetrate all the way down to them
#define ORGAN_DAMAGE_MULTIPLIER 3.5
