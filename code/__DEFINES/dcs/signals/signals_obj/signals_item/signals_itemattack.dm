// Format:
// When the signal is called: (signal arguments)
// All signals send the source datum of the signal as the first argument

/* Attack signals. They should share the returned flags, to standardize the attack chain. */
///from base of obj/item/attack(): (/mob/living/target, /mob/living/user)
#define COMSIG_ITEM_ATTACK "item_attack"

#define COMSIG_MOB_ITEM_ATTACKBY "item_attackby"
///from base of obj/item/attack_self(): (/mob)
#define COMSIG_ITEM_ATTACK_SELF "item_attack_self"
///from base of obj/item/attack_atom(): (/obj, /mob)
#define COMSIG_ITEM_ATTACK_OBJ "item_attack_obj"
///from base of obj/item/pre_attack(): (atom/target, mob/user, params)
#define COMSIG_ITEM_PRE_ATTACK "item_pre_attack"
///from base of obj/item/afterattack(): (atom/target, mob/user, params)
#define COMSIG_ITEM_AFTERATTACK "item_afterattack"
///from base of obj/item/attack_qdeleted(): (atom/target, mob/user, params)
#define COMSIG_ITEM_ATTACK_QDELETED "item_attack_qdeleted"
