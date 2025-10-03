// Format:
// When the signal is called: (signal arguments)
// All signals send the source datum of the signal as the first argument

/* Attack signals. They should share the returned flags, to standardize the attack chain. */
///from base of obj/item/attack(): (/mob/living/target, /mob/living/user)
#define COMSIG_ITEM_ATTACK "item_attack"

#define COMSIG_MOB_ITEM_ATTACKBY "item_attackby"
///from base of obj/item/attack_self(): (/mob)
#define COMSIG_ITEM_ATTACK_SELF "item_attack_self"
//from base of obj/item/attack_self_secondary(): (/mob)
#define COMSIG_ITEM_ATTACK_SELF_SECONDARY "item_attack_self_secondary"
///from base of obj/item/attack_atom(): (/obj, /mob)
#define COMSIG_ITEM_ATTACK_OBJ "item_attack_obj"
///from base of obj/item/pre_ranged_attack(): (atom/target, mob/user, params)
#define COMSIG_ITEM_RANGED_ATTACK "item_pre_ranged_attack"
	//COMPONENT_CANCEL_ATTACK_CHAIN
	//COMPONENT_SKIP_ATTACK
///from base of obj/item/pre_attack(): (atom/target, mob/user, params)
#define COMSIG_ITEM_PRE_ATTACK "item_pre_attack"
	//COMPONENT_CANCEL_ATTACK_CHAIN
	//COMPONENT_SKIP_ATTACK
/// From base of [/obj/item/proc/pre_ranged_attack_secondary()]: (atom/target, mob/user, params)
#define COMSIG_ITEM_RANGED_ATTACK_SECONDARY "item_pre_ranged_attack_secondary"
	// COMPONENT_SECONDARY_CANCEL_ATTACK_CHAIN
	// COMPONENT_SECONDARY_CONTINUE_ATTACK_CHAIN
	// COMPONENT_SECONDARY_CALL_NORMAL_ATTACK_CHAIN
/// From base of [/obj/item/proc/pre_attack_secondary()]: (atom/target, mob/user, params)
#define COMSIG_ITEM_PRE_ATTACK_SECONDARY "item_pre_attack_secondary"
	#define COMPONENT_SECONDARY_CANCEL_ATTACK_CHAIN (1<<0)
	#define COMPONENT_SECONDARY_CONTINUE_ATTACK_CHAIN (1<<1)
	#define COMPONENT_SECONDARY_CALL_NORMAL_ATTACK_CHAIN (1<<2)
/// From base of [/obj/item/proc/attack_secondary()]: (atom/target, mob/user, params)
#define COMSIG_ITEM_ATTACK_SECONDARY "item_pre_attack_secondary"
///from base of obj/item/afterattack(): (atom/target, mob/user, params)
#define COMSIG_ITEM_AFTERATTACK "item_afterattack"
///from base of obj/item/afterattack_secondary(): (atom/target, mob/user, proximity_flag, click_parameters)
#define COMSIG_ITEM_AFTERATTACK_SECONDARY "item_afterattack_secondary"
///from base of obj/item/attack_qdeleted(): (atom/target, mob/user, params)
#define COMSIG_ITEM_ATTACK_QDELETED "item_attack_qdeleted"
