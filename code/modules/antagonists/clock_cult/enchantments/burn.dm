/datum/component/enchantment/burn
	max_level = 3

/datum/component/enchantment/burn/apply_effect(obj/item/target)
	examine_description = "It has been blessed with the power of fire and will set striked targets on fire."
	target.w_class = WEIGHT_CLASS_TINY
	target.damtype = BURN
	RegisterSignal(target, COMSIG_ITEM_ATTACK, PROC_REF(burn_target))

/datum/component/enchantment/burn/proc/burn_target(datum/source, atom/movable/target, mob/living/user)
	if(!isliving(target))
		return
	var/mob/living/L = target
	L.adjust_fire_stacks(level)
	L.IgniteMob()
