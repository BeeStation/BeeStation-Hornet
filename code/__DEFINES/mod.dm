/// Default value for the max_complexity var on MODsuits
#define DEFAULT_MAX_COMPLEXITY 15

/// Default cell drain per process on MODsuits
#define DEFAULT_CHARGE_DRAIN 5

/// Default time for a part of the suit to seal.
#define MOD_ACTIVATION_STEP_TIME (1 SECONDS)

/// Passive module, just acts when put in naturally.
#define MODULE_PASSIVE 0
/// Usable module, does something when you press a button.
#define MODULE_USABLE 1
/// Toggle module, you turn it on/off and it does stuff.
#define MODULE_TOGGLE 2
/// Actively usable module, you may only have one selected at a time.
#define MODULE_ACTIVE 3

/// This module can be used during phaseout
#define MODULE_ALLOW_PHASEOUT (1<<0)
/// This module can be used while incapacitated
#define MODULE_ALLOW_INCAPACITATED (1<<1)
/// This module can be used while the suit is off
#define MODULE_ALLOW_INACTIVE (1<<2)

#define UNSEALED_LAYER "unsealed_layer"
#define SEALED_LAYER "sealed_layer"
#define UNSEALED_CLOTHING "unsealed_clothing"
#define SEALED_CLOTHING "sealed_clothing"
#define UNSEALED_INVISIBILITY "unsealed_invisibility"
#define SEALED_INVISIBILITY "sealed_invisibility"
#define UNSEALED_COVER "unsealed_cover"
#define SEALED_COVER "sealed_cover"
#define CAN_OVERSLOT "can_overslot"
#define UNSEALED_MESSAGE "unsealed_message"
#define SEALED_MESSAGE "sealed_message"

//Defines used to override MOD clothing's icon and worn icon files in the skin.
#define MOD_ICON_OVERRIDE "mod_icon_override"
#define MOD_WORN_ICON_OVERRIDE "mod_worn_icon_override"

//Default text for different messages for the user.
#define HELMET_UNSEAL_MESSAGE "hisses open"
#define HELMET_SEAL_MESSAGE "hisses closed"
#define CHESTPLATE_UNSEAL_MESSAGE "releases your chest"
#define CHESTPLATE_SEAL_MESSAGE "cinches tightly around your chest"
#define GAUNTLET_UNSEAL_MESSAGE "become loose around your fingers"
#define GAUNTLET_SEAL_MESSAGE "tighten around your fingers and wrists"
#define BOOT_UNSEAL_MESSAGE "relax their grip on your legs"
#define BOOT_SEAL_MESSAGE "seal around your feet"

/// Global list of all /datum/mod_theme
GLOBAL_LIST_INIT(mod_themes, setup_mod_themes())
/// Global cache of mod skins to masks per different configuration of pulled out parts.
GLOBAL_LIST_EMPTY(mod_masks)
/// Global cache of mod skins to deployed parts to module icon states
GLOBAL_LIST_EMPTY(mod_module_overlays)
