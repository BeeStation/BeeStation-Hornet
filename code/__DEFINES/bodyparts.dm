#define IS_ORGANIC_LIMB(A) (A && (A.bodytype & BODYTYPE_ORGANIC))
#define IS_ROBOTIC_LIMB(A) (A && (A.bodytype & BODYTYPE_ROBOTIC))

#define BODYZONE_STYLE_DEFAULT 0
#define BODYZONE_STYLE_MEDICAL 1

#define BODYZONE_CONTEXT_COMBAT 0
#define BODYZONE_CONTEXT_INJECTION 1
#define BODYZONE_CONTEXT_ROBOTIC_LIMB_HEALING 2

/// Amount of injury damage taken when the damage is blunt
#define BLUNT_DAMAGE_RATIO 0.5
/// Point at which injury damage starts to turn blunt
#define BLUNT_DAMAGE_START 30
/// Point at which damage can no longer apply
#define INJURY_PENETRATION_MINIMUM -20
