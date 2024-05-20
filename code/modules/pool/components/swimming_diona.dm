/datum/component/swimming/diona/enter_pool()
	var/mob/living/L = parent
	to_chat(L, "<span class='userdanger'>You feel yourself growing from the water!</span>")

/datum/component/swimming/diona/process()
	..()
	var/mob/living/L = parent
	if(DT_PROB(20, delta_time))
		reagents.add_reagent(/datum/reagent/growthserum, 2)
