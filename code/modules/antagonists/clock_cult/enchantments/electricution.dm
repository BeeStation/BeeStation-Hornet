/datum/component/enchantment/electricution
	max_level = 3
	var/tesla_flags = TESLA_OBJ_DAMAGE
	var/zap_range = 1
	var/power = 10000

/datum/component/enchantment/electricution/apply_effect(obj/item/target)
	examine_description = "It has been blessed with the power of electricity and will shock targets in an area."
	RegisterSignal(target, COMSIG_ITEM_ATTACK, PROC_REF(shock_target))
	zap_range = level
	power = (level * 10000)
	target.siemens_coefficient = 0

/datum/component/enchantment/electricution/proc/shock_target(datum/source, atom/movable/target, mob/living/user)
	tesla_zap(target, zap_range, power, tesla_flags)
