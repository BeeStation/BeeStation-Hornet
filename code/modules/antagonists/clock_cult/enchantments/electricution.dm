/datum/component/enchantment/electricution
	max_level = 3

/datum/component/enchantment/electricution/apply_effect(obj/item/target)
	examine_description = "It has been blessed with the power of electricity and will shock targets."
	RegisterSignal(target, COMSIG_ITEM_ATTACK, PROC_REF(shock_target))

/datum/component/enchantment/electricution/proc/shock_target(datum/source, atom/movable/target, mob/living/user)
	user.Beam(target, icon_state="lightning[rand(1,12)]", time=2, maxdistance = 32)
	if(!iscarbon(target))
		return
	var/mob/living/carbon/C = target
	if(C.electrocute_act(level * 3, user, 1, FALSE, FALSE, FALSE, FALSE, FALSE))
		C.visible_message("<span class='danger'>[user] electrocutes [target]!</span>","<span class='userdanger'>[user] electrocutes you!</span>")
