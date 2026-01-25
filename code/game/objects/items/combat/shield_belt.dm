#define COLOUR_GOOD "#5eabeb"
#define COLOUR_BAD "#cb5858"

/obj/item/shield_belt
	name = "shield belt"
	desc = "A belt that engulfs the user in a shield that blocks both incoming and outgoing high-energy projectiles."
	slot_flags = ITEM_SLOT_BELT
	icon = 'icons/obj/clothing/belts.dmi'
	icon_state = "shield_belt"
	inhand_icon_state = "security"
	worn_icon_state = "shield_belt"
	lefthand_file = 'icons/mob/inhands/equipment/belt_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/equipment/belt_righthand.dmi'
	var/max_shield_integrity = 80

/obj/item/shield_belt/Initialize(mapload)
	. = ..()
	AddComponent(/datum/component/shielded, max_integrity = max_shield_integrity, charge_recovery = 10, shield_flags = ENERGY_SHIELD_BLOCK_PROJECTILES | ENERGY_SHIELD_INVISIBLE | ENERGY_SHIELD_EMP_VULNERABLE | ENERGY_SHIELD_DEPLETE_EQUIP, on_active_effects = CALLBACK(src, PROC_REF(add_shield_effects)), on_deactive_effects = CALLBACK(src, PROC_REF(remove_shield_effects)), on_integrity_changed = CALLBACK(src, PROC_REF(update_shield_health)))

/obj/item/shield_belt/proc/add_shield_effects(mob/living/wearer, current_integrity)
	RegisterSignal(wearer, COMSIG_MOB_BEFORE_FIRE_GUN, PROC_REF(intercept_gun_fire))
	update_shield_health(wearer, current_integrity)

/obj/item/shield_belt/proc/remove_shield_effects(mob/living/wearer, current_integrity)
	UnregisterSignal(wearer, COMSIG_MOB_BEFORE_FIRE_GUN)
	wearer.remove_filter("shield_filter")

/obj/item/shield_belt/proc/update_shield_health(mob/living/wearer, current_integrity)
	if (current_integrity <= 0)
		wearer.remove_filter("shield_filter")
		return
	var/list/good = rgb2num(COLOUR_GOOD)
	var/list/bad = rgb2num(COLOUR_BAD)
	var/proportion = current_integrity / max_shield_integrity
	var/colour_first = rgb(proportion * good[1] + (1 - proportion) * bad[1], proportion * good[2] + (1 - proportion) * bad[2], proportion * good[3] + (1 - proportion) * bad[3], 70)
	var/colour_second = rgb((proportion * good[1] + (1 - proportion) * bad[1]) * 0.8, (proportion * good[2] + (1 - proportion) * bad[2]) * 0.8, (proportion * good[3] + (1 - proportion) * bad[3]) * 0.8, 70)
	wearer.add_filter("shield_filter", 10, outline_filter(2, colour_first))
	// Do the animation
	wearer.transition_filter("shield_filter", 2 SECONDS, list(size = 2, color = colour_second), easing = SINE_EASING, loop = -1)
	animate(time = 2 SECONDS, color = colour_first, easing = SINE_EASING, loop = -1)

/// Intercept outgoing gunfire
/obj/item/shield_belt/proc/intercept_gun_fire(mob/source, obj/item/gun, atom/target, aimed)
	SIGNAL_HANDLER
	return GUN_HIT_SELF

#undef COLOUR_GOOD
#undef COLOUR_BAD
