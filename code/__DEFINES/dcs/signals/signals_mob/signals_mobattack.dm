// Format:
// When the signal is called: (signal arguments)
// All signals send the source datum of the signal as the first argument

/* Attack signals. They should share the returned flags, to standardize the attack chain. */

/// from base of /obj/item/attack(): (mob/living/target_mob, mob/living/user, list/modifiers)
#define COMSIG_ITEM_ATTACK "item_attack"
/// from base of /obj/item/attack(): (mob/living/target_mob, mob/living/user, list/modifiers)
#define COMSIG_MOB_ITEM_ATTACK "mob_item_attack"
/// from base of /obj/item/attack(): (mob/living/user, obj/item/attacking_item)
#define COMSIG_MOB_ITEM_ATTACKBY "item_attackby"
/// from base of /obj/item/afterattack(): (atom/target, mob/user, proximity_flag, list/modifiers)
#define COMSIG_MOB_ITEM_AFTERATTACK "mob_item_afterattack"
/// from base of /obj/item/afterattack_secondary(): (atom/target, obj/item/weapon, proximity_flag, list/modifiers)
#define COMSIG_MOB_ITEM_AFTERATTACK_SECONDARY "mob_item_afterattack_secondary"
/// from base of /atom/attack_hand(): (mob/user)
#define COMSIG_MOB_ATTACK_HAND "mob_attack_hand"
/// from base of /mob/RangedAttack(): (atom/A, modifiers)
#define COMSIG_MOB_ATTACK_RANGED "mob_attack_ranged"
