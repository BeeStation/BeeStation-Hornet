#define COLOUR_GOOD "#5eabeb"
#define COLOUR_BAD "#cb5858"

/obj/item/shield_belt
	name = "shield belt"
	desc = "A belt that engulfs the user in a shield that blocks both incoming and outgoing high-energy projectiles."
	slot_flags = ITEM_SLOT_BELT
	icon = 'icons/obj/clothing/belts.dmi'
	icon_state = "shield_belt"
	item_state = "security"
	worn_icon_state = "shield_belt"
	lefthand_file = 'icons/mob/inhands/equipment/belt_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/equipment/belt_righthand.dmi'
	var/max_shield_integrity = 80

/obj/item/shield_belt/ComponentInitialize()
	. = ..()
	AddComponent(/datum/component/shielded, max_integrity = max_shield_integrity, charge_recovery = 10, shield_flags = ENERGY_SHIELD_BLOCK_PROJECTILES | ENERGY_SHIELD_INVISIBLE | ENERGY_SHIELD_EMP_VULNERABLE, on_active_effects = CALLBACK(src, PROC_REF(add_shield_effects)), on_deactive_effects = CALLBACK(src, PROC_REF(remove_shield_effects)))

/obj/item/shield_belt/proc/add_shield_effects(mob/living/wearer, current_integrity)
	RegisterSignal(wearer, COMSIG_MOB_BEFORE_FIRE_GUN, PROC_REF(intercept_gun_fire))

/obj/item/shield_belt/proc/remove_shield_effects(mob/living/wearer, current_integrity)
	UnregisterSignal(wearer, COMSIG_MOB_BEFORE_FIRE_GUN)

/// Intercept outgoing gunfire
/obj/item/shield_belt/proc/intercept_gun_fire(mob/source, obj/item/gun, atom/target, aimed)
	SIGNAL_HANDLER
	return GUN_HIT_SELF

#undef COLOUR_GOOD
#undef COLOUR_BAD
