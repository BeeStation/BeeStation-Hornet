/datum/pain_source/carbon

/datum/pain_source/carbon/register_signals()
	..()
	RegisterSignal(owner, COMSIG_LIVING_HEALTH_UPDATE, PROC_REF(on_health_update))

/datum/pain_source/carbon/proc/on_health_update()
	var/mob/living/carbon/carbon_owner = owner
	var/pain_base = 0
	for (var/obj/item/bodypart/bodypart in carbon_owner.bodyparts)
		var/bodypart_damage = bodypart.get_damage()
		pain_base += bodypart_damage * bodypart.pain_multiplier
	set_pain_source(pain_base, FROM_PAIN_BASE)
