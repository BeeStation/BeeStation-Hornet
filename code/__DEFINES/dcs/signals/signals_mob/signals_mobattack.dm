// Format:
// When the signal is called: (signal arguments)
// All signals send the source datum of the signal as the first argument

/* Attack signals. They should share the returned flags, to standardize the attack chain. */

///from base of atom/attack_hand(): (mob/user)
#define COMSIG_MOB_ATTACK_HAND "mob_attack_hand"
///from base of /obj/item/attack(): (mob/M, mob/user)
#define COMSIG_MOB_ITEM_ATTACK "mob_item_attack"
///from base of obj/item/afterattack(): (atom/target, mob/user, proximity_flag, click_parameters)
#define COMSIG_MOB_ITEM_AFTERATTACK "mob_item_afterattack"
///from base of obj/item/afterattack_secondary(): (atom/target, obj/item/weapon, proximity_flag, click_parameters)
#define COMSIG_MOB_ITEM_AFTERATTACK_SECONDARY "mob_item_afterattack_secondary"
///from base of obj/item/attack_qdeleted(): (atom/target, mob/user, proxiumity_flag, click_parameters)
#define COMSIG_MOB_ITEM_ATTACK_QDELETED "mob_item_attack_qdeleted"
///from base of mob/RangedAttack(): (atom/A, modifiers)
#define COMSIG_MOB_ATTACK_RANGED "mob_attack_ranged"
///from mob/living/carbon/human/UnarmedAttack(): (atom/target, proximity)
#define COMSIG_HUMAN_EARLY_UNARMED_ATTACK "human_early_unarmed_attack"
///from mob/living/carbon/human/UnarmedAttack(): (atom/target, proximity)
#define COMSIG_HUMAN_MELEE_UNARMED_ATTACK "human_melee_unarmed_attack"
