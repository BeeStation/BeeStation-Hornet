/datum/component/swimming/diona/enter_pool()

/datum/component/swimming/diona/process(delta_time)
	..()
	var/mob/living/L = parent
	if(DT_PROB(20, delta_time))
		L.reagents.add_reagent(/datum/reagent/water, 2)
