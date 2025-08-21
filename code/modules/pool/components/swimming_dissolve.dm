/datum/component/swimming/dissolve
	var/start_alpha = 0

/datum/component/swimming/dissolve/enter_pool()
	var/mob/living/L = parent
	start_alpha = L.alpha
	to_chat(parent, span_userdanger("You begin disolving into the pool, get out fast!"))

/datum/component/swimming/dissolve/process()
	..()
	var/mob/living/L = parent
	var/mob/living/carbon/human/H = L
	if(istype(H))
		if(H.wear_suit && isclothing(H.wear_suit))
			var/obj/item/clothing/CH = H.wear_suit
			if (CH.clothing_flags & THICKMATERIAL)
				return
	L.adjustCloneLoss(1)
	L.alpha = ((L.health-HEALTH_THRESHOLD_DEAD) / (L.maxHealth - HEALTH_THRESHOLD_DEAD)) * 255
	if(L.stat == DEAD)
		L.visible_message(span_warning("[L] dissolves into the pool!"))
		var/obj/item/organ/brain = L.get_organ_by_type(/obj/item/organ/brain)
		brain.Remove(L)	//Maybe making them completely unrecoverable is too far
		brain.forceMove(get_turf(L))
		//Force all items to the ground to not delete anything important.
		for(var/obj/item/W in L)
			L.dropItemToGround(W, TRUE)
		//Delete the body.
		qdel(L)

/datum/component/swimming/dissolve/exit_pool()
	animate(parent, alpha=start_alpha, time=20)
