
/mob/living/brain/Life(delta_time = SSMOBS_DT, times_fired)
	set invisibility = 0
	if (notransform)
		return
	if(!loc)
		return
	. = ..()
	handle_emp_damage(delta_time, times_fired)

/mob/living/brain/update_stat()
	if(HAS_TRAIT(src, TRAIT_GODMODE))
		return
	if(health > HEALTH_THRESHOLD_DEAD)
		return
	if(stat != DEAD)
		death()
	var/obj/item/organ/brain/BR
	if(container?.brain)
		BR = container.brain
	else if(istype(loc, /obj/item/organ/brain))
		BR = loc
	if(BR)
		BR.brain_death = TRUE //beaten to a pulp

/mob/living/brain/proc/handle_emp_damage(delta_time, times_fired)
	if(!emp_damage)
		return

	if(stat == DEAD)
		emp_damage = 0
	else
		emp_damage = max(emp_damage - (0.5 * delta_time), 0)

/mob/living/brain/handle_traits(delta_time, times_fired)
	return
